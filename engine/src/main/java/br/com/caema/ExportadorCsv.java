package br.com.caema;

import org.postgresql.PGConnection;
import org.postgresql.copy.CopyManager;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ExportadorCsv {

    /** Uma linha do arquivo de comando. */
    private static final class Command {

        private final String sqlFile;
        private final String outputFolder;
        private final boolean exportCsv;
        private final boolean createDateSubfolder;
        private final String varsRaw;
        private final String alias;
        private final boolean zipCsv;
        private final boolean sendFtp;

        Command(String sqlFile, String outputFolder, boolean exportCsv, boolean createDateSubfolder,
                String varsRaw, String alias, boolean zipCsv, boolean sendFtp) {
            this.sqlFile = sqlFile;
            this.outputFolder = outputFolder;
            this.exportCsv = exportCsv;
            this.createDateSubfolder = createDateSubfolder;
            this.varsRaw = varsRaw;
            this.alias = alias;
            this.zipCsv = zipCsv;
            this.sendFtp = sendFtp;
        }

        String sqlFile()             { return sqlFile; }
        String outputFolder()        { return outputFolder; }
        boolean exportCsv()          { return exportCsv; }
        boolean createDateSubfolder(){ return createDateSubfolder; }
        String varsRaw()             { return varsRaw; }
        String alias()               { return alias; }
        boolean zipCsv()             { return zipCsv; }
        boolean sendFtp()            { return sendFtp; }
    }

    public static void main(String[] args) {

        if (args.length < 5) {
            System.err.println("Uso:");
            System.err.println("java -jar exportador-csv.jar <jdbcUrl> <usuario> <senha> <dirRaizJob> <arquivoComandoCsv>");
            System.exit(1);
        }

        String jdbcUrl  = args[0];
        String usuario  = args[1];
        String senha    = args[2];
        Path rootDir    = Paths.get(args[3]);
        Path comandoCsv = Paths.get(args[4]);

        Path sqlDir   = rootDir.resolve("sql");
        Path saidaDir = rootDir.resolve("saida");
        Path logDir   = rootDir.resolve("log");

        // Nome do projeto (ex.: COMANDO_MADRUGADA), usado como pasta final em disco e no FTP.
        String nomeComando = tirarExtensao(comandoCsv.getFileName().toString());

        log(logDir, "==== INICIO EXECUCAO ENGINE ====");
        log(logDir, "ROOT_DIR: " + rootDir.toAbsolutePath());
        log(logDir, "COMANDO: " + comandoCsv.toAbsolutePath());

        List<Command> commands;

        try {
            commands = carregarComandos(comandoCsv);
        } catch (Exception e) {
            logErroCompleto(logDir, e);
            return;
        }

        FtpUploader uploader = null;

        boolean algumComandoUsaFtp = false;

        for (Command cmd : commands) {
            if (cmd.sendFtp()) {
                algumComandoUsaFtp = true;
                break;
            }
        }

        if (algumComandoUsaFtp) {
            try {
                final Path logDirFinal = logDir;

                FtpConfig ftpConfig = FtpConfig.carregar(
                        rootDir.resolve("engine").resolve("configs.properties"));

                if (ftpConfig == null) {
                    log(logDir, "FTP NAO CONFIGURADO: engine/configs.properties ausente ou sem FTP_SERVER. "
                            + "Os arquivos serao apenas gravados em disco.");
                } else {
                    uploader = new FtpUploader(ftpConfig, msg -> log(logDirFinal, msg));
                    log(logDir, "FTP DESTINO: " + ftpConfig.server() + ":" + ftpConfig.port()
                            + " (base " + ftpConfig.baseDir() + ")");
                }
            } catch (Exception e) {
                logErroCompleto(logDir, e);
            }
        }

        try (Connection conn = DriverManager.getConnection(jdbcUrl, usuario, senha)) {

            log(logDir, "CONEXAO COM BANCO OK");

            // Relatorios ordenam milhoes de linhas largas; com pouca memoria de ordenacao o banco
            // despeja o sort em disco. WORK_MEM (engine/configs.properties) sobe o limite so nesta
            // sessao, sem alterar a configuracao do servidor.
            aplicarWorkMem(conn, rootDir, logDir);

            for (Command cmd : commands) {

                if (!cmd.exportCsv()) {
                    log(logDir, "PULANDO (EXPORT_CSV=false): " + cmd.sqlFile());
                    continue;
                }

                Path sqlPath = sqlDir.resolve(cmd.sqlFile());

                if (!Files.exists(sqlPath)) {
                    log(logDir, "SQL NAO ENCONTRADO: " + sqlPath);
                    continue;
                }

                try {
                    executarComando(cmd, sqlPath, saidaDir, logDir, conn, uploader, nomeComando);
                } catch (Exception e) {
                    logErroCompleto(logDir, e);
                }
            }

        } catch (Exception e) {
            logErroCompleto(logDir, e);
        }

        log(logDir, "==== FIM EXECUCAO ENGINE ====");
    }

    /** Le WORK_MEM de engine/configs.properties e aplica na sessao. Ausente = usa o padrao do servidor. */
    private static void aplicarWorkMem(Connection conn, Path rootDir, Path logDir) {

        Path props = rootDir.resolve("engine").resolve("configs.properties");

        if (!Files.exists(props)) {
            return;
        }

        try {
            Properties p = new Properties();

            try (java.io.InputStream in = Files.newInputStream(props)) {
                p.load(new java.io.InputStreamReader(in, StandardCharsets.UTF_8));
            }

            String workMem = p.getProperty("WORK_MEM");

            if (isBlank(workMem)) {
                return;
            }

            try (java.sql.Statement st = conn.createStatement()) {
                st.execute("SET work_mem = '" + workMem.trim() + "'");
            }

            log(logDir, "WORK_MEM       : " + workMem.trim() + " (apenas nesta sessao)");

        } catch (Exception e) {
            log(logDir, "WORK_MEM NAO APLICADO: " + e.getMessage());
        }
    }

    // ================= CARREGAR CSV =================

    private static List<Command> carregarComandos(Path csv) throws IOException {

        List<Command> list = new ArrayList<>();

        try (BufferedReader r = Files.newBufferedReader(csv, StandardCharsets.UTF_8)) {

            String[] header = r.readLine().split(";", -1);

            Map<String, Integer> idx = new HashMap<>();

            for (int i = 0; i < header.length; i++) {
                idx.put(header[i].trim().toUpperCase(), i);
            }

            String line;

            while ((line = r.readLine()) != null) {

                if (isBlank(line)) continue;

                String[] c = line.split(";", -1);

                list.add(new Command(
                        get(c, idx, "COMANDO"),
                        get(c, idx, "OUTPUT_FOLDER"),
                        Boolean.parseBoolean(get(c, idx, "EXPORT_CSV")),
                        Boolean.parseBoolean(get(c, idx, "CREATE_DATE_SUBFOLDER")),
                        get(c, idx, "VARS"),
                        emptyToNull(get(c, idx, "ALIAS")),
                        Boolean.parseBoolean(get(c, idx, "ZIP_CSV")),
                        Boolean.parseBoolean(get(c, idx, "SEND_FTP"))
                ));
            }
        }

        return list;
    }

    private static String get(String[] c, Map<String, Integer> idx, String k) {
        Integer i = idx.get(k);
        return (i == null || i >= c.length) ? "" : c[i].trim();
    }

    private static String emptyToNull(String s) {
        return isBlank(s) ? null : s.trim();
    }

    // ================= EXECUCAO =================

    private static void executarComando(
            Command cmd,
            Path sqlPath,
            Path saidaDir,
            Path logDir,
            Connection conn,
            FtpUploader uploader,
            String nomeComando
    ) throws Exception {

        long inicio = System.currentTimeMillis();

        Map<String, String> vars = resolveVars(cmd.varsRaw());
        String sqlTemplate = lerArquivo(sqlPath);
        String sqlFinal = applyVars(sqlTemplate, vars);

        List<String> pendentes = findUnresolvedVars(sqlFinal);
        if (!pendentes.isEmpty()) {
            throw new IllegalStateException("VARS NAO RESOLVIDAS: " + pendentes);
        }

        String nomeBase = nomeBase(cmd, sqlPath, vars);

        // <OUTPUT_FOLDER>/[dd_MM_aaaa]/<COMANDO>, a mesma arvore usada no FTP.
        Path dirProjeto = saidaDir.resolve(cmd.outputFolder());

        if (cmd.createDateSubfolder()) {
            dirProjeto = dirProjeto.resolve(LocalDate.now().format(DATA_PASTA));
        }

        dirProjeto = dirProjeto.resolve(nomeComando);

        Files.createDirectories(dirProjeto);

        Path csvOut = dirProjeto.resolve(nomeBase + ".csv");

        log(logDir, "--------------------------------------------------");
        log(logDir, "EXECUTANDO SQL : " + sqlPath.getFileName());
        log(logDir, "ARQUIVO SAIDA  : " + csvOut.getFileName());
        log(logDir, "VARS           : " + vars);

        long linhas;

        try {
            // O COPY e o caminho rapido, mas ele grava o que o banco devolve, sem passar por Java.
            // Queries com codigo de barras precisam dos digitos verificadores calculados linha a
            // linha, entao essas saem pelo ResultSet.
            if (temColunaCodBarras(sqlFinal)) {
                log(logDir, "POS-PROCESSO   : coluna \"" + COLUNA_COD_BARRAS
                        + "\" detectada, gerando digitos verificadores linha a linha");
                linhas = exportarViaResultSet(conn, sqlFinal, csvOut);
            } else {
                linhas = exportarViaCopy(conn, sqlFinal, csvOut);
            }

        } catch (Exception e) {
            // Query falhou: o arquivo ja foi criado e ficaria no disco vazio ou pela metade.
            Files.deleteIfExists(csvOut);
            throw e;
        }

        log(logDir, "LINHAS         : " + linhas + " (" + kb(csvOut) + " KB no CSV)");

        // O COPY terminou, entao o arquivo tem que existir. Se sumiu, quem apagou foi algo de fora
        // (antivirus, sincronizacao de pasta, limpeza) - nao adianta zipar nem enviar.
        if (!Files.exists(csvOut)) {
            throw new IOException("CSV sumiu depois da exportacao: " + csvOut
                    + " - suspeite de antivirus, sincronizacao de pasta (OneDrive/Documentos)"
                    + " ou limpeza automatica. Rode o job em um diretorio local simples, fora de Documentos.");
        }

        // Com ZIP_CSV=true sobe o zip; sem ele, sobe o proprio CSV.
        Path arquivoFinal = csvOut;

        if (cmd.zipCsv()) {
            arquivoFinal = Arquivos.zip(csvOut);
            log(logDir, "ARQUIVO ZIP    : " + arquivoFinal.getFileName()
                    + " (" + kb(arquivoFinal) + " KB)");
        }

        if (cmd.sendFtp()) {

            if (uploader == null) {
                log(logDir, "FTP IGNORADO   : sem configuracao de FTP para " + arquivoFinal.getFileName());
            } else {
                String remoteRelPath = saidaDir.relativize(dirProjeto).toString().replace('\\', '/');
                int enviados = uploader.enviar(Collections.singletonList(arquivoFinal), remoteRelPath);
                log(logDir, "FTP ENVIADOS   : " + enviados + "/1 arquivo(s) em " + remoteRelPath);
            }
        }

        // Zipado e ja enviado: o CSV cru nao precisa ocupar espaco em disco.
        if (cmd.zipCsv()) {
            Files.deleteIfExists(csvOut);
        }

        long duracao = System.currentTimeMillis() - inicio;
        log(logDir, "SUCESSO (" + duracao + " ms)");
    }

    // ================= GRAVACAO DO CSV =================

    /** Rotulo da coluna que carrega o codigo de barras, o mesmo usado pelo gerador antigo. */
    private static final String COLUNA_COD_BARRAS = "COD BARRAS";

    /** Coluna com a referencia da conta, necessaria para calcular o digito de "D". */
    private static final String COLUNA_REFERENCIA = "REFERENCIA";

    private static final char CSV_DELIMITER = ';';

    private static boolean temColunaCodBarras(String sql) {
        return sql.contains("\"" + COLUNA_COD_BARRAS + "\"");
    }

    /** Caminho padrao: o banco monta o CSV e a engine so grava os bytes. */
    private static long exportarViaCopy(Connection conn, String sqlFinal, Path csvOut) throws Exception {

        PGConnection pgConn = conn.unwrap(PGConnection.class);
        CopyManager copyManager = pgConn.getCopyAPI();

        // As quebras de linha sao obrigatorias: varios SQLs terminam em comentario "--", e sem elas
        // o parentese de fechamento cairia dentro do comentario, invalidando a query.
        String copySql = "COPY (\n" + removerPontoVirgula(sqlFinal) +
                "\n) TO STDOUT WITH (FORMAT CSV, HEADER, DELIMITER ';')";

        try (OutputStream out = Files.newOutputStream(
                csvOut,
                StandardOpenOption.CREATE,
                StandardOpenOption.TRUNCATE_EXISTING)) {

            // copyOut devolve as linhas de dados; o cabecalho do CSV nao conta.
            return copyManager.copyOut(copySql, out);
        }
    }

    /**
     * Caminho com pos-processamento: cada linha passa por Java para o codigo de barras receber os
     * digitos verificadores. O CSV gerado aqui tem que ser identico ao do COPY, por isso a
     * formatacao dos campos segue as mesmas regras (ver escreverCampo).
     */
    private static long exportarViaResultSet(Connection conn, String sqlFinal, Path csvOut) throws Exception {

        boolean autoCommitOriginal = conn.getAutoCommit();

        // O cursor so streama com autocommit desligado; sem isso o driver traz tudo para a memoria.
        conn.setAutoCommit(false);

        try (java.sql.Statement st = conn.createStatement();
             java.io.BufferedWriter w = Files.newBufferedWriter(
                     csvOut,
                     StandardCharsets.UTF_8,
                     StandardOpenOption.CREATE,
                     StandardOpenOption.TRUNCATE_EXISTING)) {

            st.setFetchSize(10_000);

            try (java.sql.ResultSet rs = st.executeQuery(removerPontoVirgula(sqlFinal))) {

                java.sql.ResultSetMetaData meta = rs.getMetaData();
                int cols = meta.getColumnCount();

                int codBarrasIdx = -1;
                int referenciaIdx = -1;

                StringBuilder header = new StringBuilder(1024);

                for (int i = 1; i <= cols; i++) {

                    String label = meta.getColumnLabel(i);

                    if (COLUNA_COD_BARRAS.equals(label))  codBarrasIdx = i;
                    if (COLUNA_REFERENCIA.equals(label))  referenciaIdx = i;

                    if (i > 1) header.append(CSV_DELIMITER);

                    escreverCampo(header, label);
                }

                if (codBarrasIdx > 0 && referenciaIdx < 0) {
                    throw new IllegalStateException("CODIGO DE BARRAS SEM REFERENCIA PARA VALIDAR: a query tem"
                            + " a coluna \"" + COLUNA_COD_BARRAS + "\" mas nao tem \"" + COLUNA_REFERENCIA
                            + "\", que e de onde sai o digito verificador.");
                }

                header.append('\n');
                w.write(header.toString());

                long linhas = 0;
                StringBuilder line = new StringBuilder(1024);

                while (rs.next()) {

                    line.setLength(0);

                    for (int i = 1; i <= cols; i++) {

                        if (i > 1) line.append(CSV_DELIMITER);

                        // getString devolve a representacao textual do proprio servidor, que e
                        // exatamente a que o COPY grava. Assim os dois caminhos geram o mesmo CSV.
                        String value = rs.getString(i);

                        if (i == codBarrasIdx && value != null) {
                            value = CodigoBarras.getFullCodBarras(value, rs.getInt(referenciaIdx));
                        }

                        escreverCampo(line, value);
                    }

                    line.append('\n');
                    w.write(line.toString());

                    linhas++;
                }

                return linhas;
            }

        } finally {
            // A query e somente leitura; o rollback so encerra a transacao aberta pelo cursor.
            try { conn.rollback(); } catch (Exception ignored) { }
            try { conn.setAutoCommit(autoCommitOriginal); } catch (Exception ignored) { }
        }
    }

    /** Formata um campo como o COPY ... FORMAT CSV faz: copia literal de FrazoUtils.writeCsvField. */
    private static void escreverCampo(StringBuilder out, String value) {

        if (value == null) {
            return;
        }

        if (value.isEmpty()) {
            // O COPY cita a string vazia para distingui-la de NULL, que sai sem aspas.
            out.append("\"\"");
            return;
        }

        boolean needsQuote = value.indexOf(CSV_DELIMITER) >= 0
                || value.indexOf('"') >= 0
                || value.indexOf('\n') >= 0
                || value.indexOf('\r') >= 0;

        if (!needsQuote) {
            out.append(value);
            return;
        }

        out.append('"');

        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            if (c == '"') out.append('"');
            out.append(c);
        }

        out.append('"');
    }

    /**
     * ALIAS vazio ou AUTO reproduz o nome do gerador antigo, que e o padrao ja existente no FTP:
     *
     *     <SQL sem extensao>_<valor de cada VAR>_<dd_MM_aaaa_HH_mm_ss>_result.csv
     */
    private static String nomeBase(Command cmd, Path sqlPath, Map<String, String> vars) {

        if (cmd.alias() != null && !cmd.alias().equalsIgnoreCase("AUTO")) {
            return sanitize(cmd.alias());
        }

        StringBuilder sb = new StringBuilder(tirarExtensao(sqlPath.getFileName().toString()));

        for (String valor : vars.values()) {
            sb.append('_').append(valor);
        }

        sb.append('_')
          .append(LocalDateTime.now().format(CARIMBO_ARQUIVO))
          .append("_result");

        return sanitize(sb.toString());
    }

    // ================= VARS =================

    private static Map<String, String> resolveVars(String raw) {
        Map<String, List<String>> parsed = parseVars(raw);
        Map<String, String> out = new LinkedHashMap<>();

        for (Map.Entry<String, List<String>> e : parsed.entrySet()) {
            out.put(e.getKey(), resolveVar(e.getKey(), e.getValue()));
        }
        return out;
    }

    private static Map<String, List<String>> parseVars(String raw) {
        Map<String, List<String>> map = new LinkedHashMap<>();
        if (isBlank(raw)) return map;

        String current = null;

        for (String t : raw.split(",")) {
            t = t.trim();
            if (t.startsWith("VAR_") && t.contains("=")) {
                current = t.substring(0, t.indexOf('='));
                if (!map.containsKey(current)) {
                    map.put(current, new ArrayList<String>());
                }
                map.get(current).add(t.substring(t.indexOf('=') + 1));
            } else if (current != null) {
                map.get(current).add(t);
            }
        }

        return map;
    }

    private static String resolveVar(String key, List<String> values) {

        List<String> out = new ArrayList<>();

        for (String v : values) {

            if ("THIS".equalsIgnoreCase(v))
                v = LocalDate.now().format(REFERENCIA);

            // AUTO e ANT sao a referencia fechada, ou seja, o mes anterior.
            if ("ANT".equalsIgnoreCase(v) || "AUTO".equalsIgnoreCase(v))
                v = LocalDate.now().minusMonths(1).format(REFERENCIA);

            if ("VAR_UNIDADE".equalsIgnoreCase(key))
                v = v.replace("/", "");

            if (!isBlank(v))
                out.add(v);
        }

        return String.join(",", out);
    }

    private static String applyVars(String sql, Map<String, String> vars) {
        for (Map.Entry<String, String> e : vars.entrySet()) {
            sql = sql.replace("${" + e.getKey() + "}", e.getValue());
        }
        return sql;
    }

    /** Formato das pastas de data, igual ao do gerador antigo e ao que ja existe no FTP. */
    private static final DateTimeFormatter DATA_PASTA =
            DateTimeFormatter.ofPattern("dd_MM_yyyy");

    /** Referencia de faturamento (aaaaMM), formato usado pelas VARS THIS/ANT/AUTO. */
    private static final DateTimeFormatter REFERENCIA =
            DateTimeFormatter.ofPattern("yyyyMM");

    /**
     * Carimbo no nome do arquivo quando ALIAS=AUTO. O gerador antigo usava "hh" (12 horas),
     * o que fazia 20h virar 08; aqui e "HH" para o nome nunca ficar ambiguo.
     */
    private static final DateTimeFormatter CARIMBO_ARQUIVO =
            DateTimeFormatter.ofPattern("dd_MM_yyyy_HH_mm_ss");

    private static final Pattern VAR_PATTERN =
            Pattern.compile("\\$\\{(VAR_[A-Za-z0-9_]+)\\}");

    private static List<String> findUnresolvedVars(String sql) {
        Matcher m = VAR_PATTERN.matcher(sql);
        Set<String> out = new LinkedHashSet<>();
        while (m.find()) out.add(m.group(1));
        return new ArrayList<>(out);
    }

    // ================= LOG =================

    private static synchronized void log(Path logDir, String msg) {

        String time = LocalTime.now().format(HORA_LOG);
        String line = "[" + time + "] " + msg;

        System.out.println(line);

        gravarLog(logDir, line + System.lineSeparator());
    }

    private static synchronized void logErroCompleto(Path logDir, Throwable e) {

        String time = LocalTime.now().format(HORA_LOG);

        StringBuilder sb = new StringBuilder();
        sb.append("[").append(time).append("] ERRO: ")
          .append(e.getClass().getName())
          .append(" - ")
          .append(e.getMessage())
          .append(System.lineSeparator());

        for (StackTraceElement el : e.getStackTrace()) {
            sb.append("    at ").append(el).append(System.lineSeparator());
        }

        String full = sb.toString();

        System.err.println(full);

        gravarLog(logDir, full);
    }

    private static void gravarLog(Path logDir, String texto) {
        try {
            Files.createDirectories(logDir);

            Path logFile = logDir.resolve(
                    "execucao_" + LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE) + ".log"
            );

            Files.write(
                    logFile,
                    texto.getBytes(StandardCharsets.UTF_8),
                    StandardOpenOption.CREATE,
                    StandardOpenOption.APPEND
            );

        } catch (IOException e) {
            System.err.println("ERRO AO ESCREVER LOG: " + e.getMessage());
        }
    }

    private static final DateTimeFormatter HORA_LOG =
            DateTimeFormatter.ofPattern("HH:mm:ss");

    // ================= UTIL =================

    /** String.isBlank() so existe do Java 11 em diante. */
    static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private static String lerArquivo(Path arquivo) throws IOException {
        return new String(Files.readAllBytes(arquivo), StandardCharsets.UTF_8);
    }

    private static String sanitize(String s) {
        return s.replaceAll("[\\\\/:*?\"<>|]", "_");
    }

    /**
     * Tamanho do arquivo em KB para o log. Nunca lanca excecao: uma linha de log nao pode
     * derrubar um comando que ja custou horas de banco.
     */
    private static String kb(Path arquivo) {
        try {
            return String.format("%,d", Math.round(Files.size(arquivo) / 1024.0));
        } catch (IOException e) {
            return "?";
        }
    }

    private static String tirarExtensao(String f) {
        int i = f.lastIndexOf('.');
        return i < 0 ? f : f.substring(0, i);
    }

    private static String removerPontoVirgula(String sql) {
        sql = sql.trim();
        if (sql.endsWith(";"))
            return sql.substring(0, sql.length() - 1);
        return sql;
    }
}

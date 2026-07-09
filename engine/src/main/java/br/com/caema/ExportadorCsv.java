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
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.regex.Pattern;

public class ExportadorCsv {

    private record Command(
            String sqlFile,
            String outputFolder,
            boolean exportCsv,
            boolean createDateSubfolder,
            String varsRaw,
            String alias
    ) {}

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

        try (Connection conn = DriverManager.getConnection(jdbcUrl, usuario, senha)) {

            log(logDir, "CONEXAO COM BANCO OK");

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
                    executarComando(cmd, sqlPath, saidaDir, logDir, conn);
                } catch (Exception e) {
                    logErroCompleto(logDir, e);
                }
            }

        } catch (Exception e) {
            logErroCompleto(logDir, e);
        }

        log(logDir, "==== FIM EXECUCAO ENGINE ====");
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

                if (line.isBlank()) continue;

                String[] c = line.split(";", -1);

                list.add(new Command(
                        get(c, idx, "COMANDO"),
                        get(c, idx, "OUTPUT_FOLDER"),
                        Boolean.parseBoolean(get(c, idx, "EXPORT_CSV")),
                        Boolean.parseBoolean(get(c, idx, "CREATE_DATE_SUBFOLDER")),
                        get(c, idx, "VARS"),
                        emptyToNull(get(c, idx, "ALIAS"))
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
        return (s == null || s.isBlank()) ? null : s.trim();
    }

    // ================= EXECUCAO =================

    private static void executarComando(
            Command cmd,
            Path sqlPath,
            Path saidaDir,
            Path logDir,
            Connection conn
    ) throws Exception {

        long inicio = System.currentTimeMillis();

        Map<String, String> vars = resolveVars(cmd.varsRaw());
        String sqlTemplate = Files.readString(sqlPath, StandardCharsets.UTF_8);
        String sqlFinal = applyVars(sqlTemplate, vars);

        List<String> pendentes = findUnresolvedVars(sqlFinal);
        if (!pendentes.isEmpty()) {
            throw new IllegalStateException("VARS NAO RESOLVIDAS: " + pendentes);
        }

        String nomeBase = (cmd.alias() != null)
                ? sanitize(cmd.alias())
                : tirarExtensao(sqlPath.getFileName().toString());

        Path dirProjeto = saidaDir.resolve(cmd.outputFolder());

        if (cmd.createDateSubfolder()) {
            dirProjeto = dirProjeto.resolve(
                    LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE));
        }

        Files.createDirectories(dirProjeto);

        Path csvOut = dirProjeto.resolve(nomeBase + ".csv");

        log(logDir, "--------------------------------------------------");
        log(logDir, "EXECUTANDO SQL : " + sqlPath.getFileName());
        log(logDir, "ARQUIVO SAIDA  : " + csvOut.getFileName());
        log(logDir, "VARS           : " + vars);

        PGConnection pgConn = conn.unwrap(PGConnection.class);
        CopyManager copyManager = pgConn.getCopyAPI();

        String copySql = "COPY (" + removerPontoVirgula(sqlFinal) +
                ") TO STDOUT WITH (FORMAT CSV, HEADER, DELIMITER ';')";

        try (OutputStream out = Files.newOutputStream(
                csvOut,
                StandardOpenOption.CREATE,
                StandardOpenOption.TRUNCATE_EXISTING)) {

            copyManager.copyOut(copySql, out);
        }

        long duracao = System.currentTimeMillis() - inicio;
        log(logDir, "SUCESSO (" + duracao + " ms)");
    }

    // ================= VARS =================

    private static Map<String, String> resolveVars(String raw) {
        Map<String, List<String>> parsed = parseVars(raw);
        Map<String, String> out = new LinkedHashMap<>();

        for (var e : parsed.entrySet()) {
            out.put(e.getKey(), resolveVar(e.getKey(), e.getValue()));
        }
        return out;
    }

    private static Map<String, List<String>> parseVars(String raw) {
        Map<String, List<String>> map = new LinkedHashMap<>();
        if (raw == null || raw.isBlank()) return map;

        String current = null;

        for (String t : raw.split(",")) {
            t = t.trim();
            if (t.startsWith("VAR_") && t.contains("=")) {
                current = t.substring(0, t.indexOf('='));
                map.putIfAbsent(current, new ArrayList<>());
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
                v = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMM"));

            if ("ANT".equalsIgnoreCase(v))
                v = LocalDate.now().minusMonths(1).format(DateTimeFormatter.ofPattern("yyyyMM"));

            if ("VAR_UNIDADE".equalsIgnoreCase(key))
                v = v.replace("/", "");

            if (!v.isBlank())
                out.add(v);
        }

        return String.join(",", out);
    }

    private static String applyVars(String sql, Map<String, String> vars) {
        for (var e : vars.entrySet()) {
            sql = sql.replace("${" + e.getKey() + "}", e.getValue());
        }
        return sql;
    }

    private static final Pattern VAR_PATTERN =
            Pattern.compile("\\$\\{(VAR_[A-Za-z0-9_]+)\\}");

    private static List<String> findUnresolvedVars(String sql) {
        var m = VAR_PATTERN.matcher(sql);
        Set<String> out = new LinkedHashSet<>();
        while (m.find()) out.add(m.group(1));
        return new ArrayList<>(out);
    }

    // ================= LOG =================

    private static synchronized void log(Path logDir, String msg) {

        String time = LocalTime.now().format(DateTimeFormatter.ofPattern("HH:mm:ss"));
        String line = "[" + time + "] " + msg;

        System.out.println(line);

        try {
            Files.createDirectories(logDir);

            Path logFile = logDir.resolve(
                    "execucao_" + LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE) + ".log"
            );

            Files.writeString(
                    logFile,
                    line + System.lineSeparator(),
                    StandardCharsets.UTF_8,
                    StandardOpenOption.CREATE,
                    StandardOpenOption.APPEND
            );

        } catch (IOException e) {
            System.err.println("ERRO AO ESCREVER LOG: " + e.getMessage());
        }
    }

    private static synchronized void logErroCompleto(Path logDir, Throwable e) {

        String time = LocalTime.now().format(DateTimeFormatter.ofPattern("HH:mm:ss"));

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

        try {
            Files.createDirectories(logDir);

            Path logFile = logDir.resolve(
                    "execucao_" + LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE) + ".log"
            );

            Files.writeString(
                    logFile,
                    full,
                    StandardCharsets.UTF_8,
                    StandardOpenOption.CREATE,
                    StandardOpenOption.APPEND
            );

        } catch (IOException ex) {
            System.err.println("ERRO AO ESCREVER LOG DE ERRO: " + ex.getMessage());
        }
    }

    // ================= UTIL =================

    private static String sanitize(String s) {
        return s.replaceAll("[\\\\/:*?\"<>|]", "_");
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

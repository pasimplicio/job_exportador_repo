package br.com.caema;

import org.apache.commons.net.ftp.FTP;
import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPReply;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.function.Consumer;

/**
 * Envio dos arquivos gerados para o FTP, espelhando a estrutura da pasta saida:
 *
 *     FTP_BASE_DIR / <OUTPUT_FOLDER> / [aaaaMMdd] / arquivo
 *
 * Os diretorios remotos sao criados nivel a nivel, porque o servidor nao aceita
 * MKD de caminho completo.
 */
final class FtpUploader {

    private static final int TIMEOUT_MS = 60_000;

    private final FtpConfig cfg;
    private final Consumer<String> log;

    FtpUploader(FtpConfig cfg, Consumer<String> log) {
        this.cfg = cfg;
        this.log = log;
    }

    /**
     * @param remoteRelPath caminho relativo abaixo de FTP_BASE_DIR (ex.: "Madrugada/20260713")
     * @return quantidade de arquivos enviados
     */
    int enviar(List<Path> arquivos, String remoteRelPath) throws IOException {

        if (arquivos.isEmpty()) {
            return 0;
        }

        FTPClient ftp = new FTPClient();
        ftp.setConnectTimeout(TIMEOUT_MS);
        ftp.setDefaultTimeout(TIMEOUT_MS);

        int enviados = 0;

        try {
            ftp.connect(cfg.server(), cfg.port());

            if (!FTPReply.isPositiveCompletion(ftp.getReplyCode())) {
                throw new IOException("FTP recusou a conexao: " + ftp.getReplyString().trim());
            }

            if (!ftp.login(cfg.user(), cfg.pass())) {
                throw new IOException("FTP recusou o login do usuario " + cfg.user());
            }

            ftp.setSoTimeout(TIMEOUT_MS);
            ftp.enterLocalPassiveMode();
            ftp.setFileType(FTP.BINARY_FILE_TYPE);

            String remoteDir = criarDiretorios(ftp, remoteRelPath);

            for (Path arquivo : arquivos) {

                if (!Files.exists(arquivo)) {
                    continue;
                }

                String destino = remoteDir + "/" + arquivo.getFileName();

                try (InputStream in = Files.newInputStream(arquivo)) {

                    if (ftp.storeFile(destino, in)) {
                        enviados++;
                        log.accept("FTP OK        : " + destino);
                    } else {
                        log.accept("FTP FALHOU    : " + destino + " -> " + ftp.getReplyString().trim());
                    }
                }
            }

        } finally {
            if (ftp.isConnected()) {
                try {
                    ftp.logout();
                } catch (IOException ignored) {
                    // conexao ja caiu; o disconnect abaixo resolve
                }
                ftp.disconnect();
            }
        }

        return enviados;
    }

    /** Cria (se preciso) e retorna o caminho remoto absoluto correspondente a FTP_BASE_DIR/remoteRelPath. */
    private String criarDiretorios(FTPClient ftp, String remoteRelPath) throws IOException {

        StringBuilder caminho = new StringBuilder();

        ftp.changeWorkingDirectory("/");

        String completo = (ExportadorCsv.isBlank(cfg.baseDir()) ? "" : cfg.baseDir() + "/") + remoteRelPath;

        for (String parte : completo.split("[/\\\\]")) {

            if (ExportadorCsv.isBlank(parte)) {
                continue;
            }

            caminho.append('/').append(parte);

            // MKD falha quando o diretorio ja existe; o que importa e o CWD funcionar.
            ftp.makeDirectory(caminho.toString());

            if (!ftp.changeWorkingDirectory(caminho.toString())) {
                throw new IOException("Nao foi possivel criar/acessar o diretorio remoto " + caminho);
            }
        }

        ftp.changeWorkingDirectory("/");

        return caminho.toString();
    }
}

package br.com.caema;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Properties;

/**
 * Configuracao do FTP lida de engine/configs.properties.
 * Arquivo ausente ou FTP_SERVER em branco significa "nao enviar para FTP".
 */
final class FtpConfig {

    private final String server;
    private final int port;
    private final String user;
    private final String pass;
    private final String baseDir;

    private FtpConfig(String server, int port, String user, String pass, String baseDir) {
        this.server = server;
        this.port = port;
        this.user = user;
        this.pass = pass;
        this.baseDir = baseDir;
    }

    String server()  { return server; }
    int port()       { return port; }
    String user()    { return user; }
    String pass()    { return pass; }
    String baseDir() { return baseDir; }

    static FtpConfig carregar(Path propertiesFile) throws Exception {

        if (!Files.exists(propertiesFile)) {
            return null;
        }

        Properties p = new Properties();

        try (InputStream in = Files.newInputStream(propertiesFile)) {
            p.load(new InputStreamReader(in, StandardCharsets.UTF_8));
        }

        String server = valor(p, "FTP_SERVER");

        if (server == null) {
            return null;
        }

        String portaRaw = valor(p, "FTP_PORT");
        int port = (portaRaw == null) ? 21 : Integer.parseInt(portaRaw);

        String baseDir = valor(p, "FTP_BASE_DIR");

        return new FtpConfig(
                server,
                port,
                valor(p, "FTP_USER"),
                valor(p, "FTP_PASS"),
                (baseDir == null) ? "" : baseDir
        );
    }

    private static String valor(Properties p, String chave) {
        String v = p.getProperty(chave);
        return ExportadorCsv.isBlank(v) ? null : v.trim();
    }
}

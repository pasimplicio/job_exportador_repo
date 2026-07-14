package br.com.caema;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

/** Compactacao dos arquivos gerados, no mesmo formato do gerador antigo. */
final class Arquivos {

    private static final int BUFFER = 1024 * 1024;

    private Arquivos() {}

    /**
     * Gera o zip do arquivo original mantendo o nome usado pelo gerador antigo:
     * o ponto da extensao vira underline, entao "X_result.csv" produz "X_result_csv.zip".
     */
    static Path zip(Path origem) throws IOException {

        String nome = origem.getFileName().toString();

        Path zipPath = origem.resolveSibling(nome.replace('.', '_') + ".zip");

        try (InputStream in = new BufferedInputStream(Files.newInputStream(origem), BUFFER);
             OutputStream out = Files.newOutputStream(
                     zipPath,
                     StandardOpenOption.CREATE,
                     StandardOpenOption.TRUNCATE_EXISTING);
             ZipOutputStream zos = new ZipOutputStream(out)) {

            zos.putNextEntry(new ZipEntry(nome));

            byte[] buffer = new byte[BUFFER];
            int lidos;

            while ((lidos = in.read(buffer)) != -1) {
                zos.write(buffer, 0, lidos);
            }

            zos.closeEntry();
        }

        return zipPath;
    }
}

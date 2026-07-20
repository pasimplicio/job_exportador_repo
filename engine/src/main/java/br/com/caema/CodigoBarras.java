package br.com.caema;

import java.text.ParseException;
import java.text.SimpleDateFormat;

/**
 * Preenche os digitos verificadores do codigo de barras da conta.
 *
 * A query entrega o codigo com marcadores no lugar dos digitos que so podem ser calculados
 * depois de montado o restante: "D" (digito da referencia), "X" (digito do codigo inteiro)
 * e um "H" ao fim de cada campo separado por "-". Exemplo do que sai do banco:
 *
 *     826X0000000-H 47180002111-H 00010557001-H 052026D0003-H
 *
 * Sem essa substituicao o boleto nao e pagavel. O codigo abaixo e copia literal de
 * Controle.getFullCodBarras e Controle.getDigitoVerificador do gerador antigo
 * (d:\report-generator-master), preservado como estava para nao mudar nenhum digito.
 */
final class CodigoBarras {

    private CodigoBarras() {
    }

    static String getFullCodBarras(String codBarras, int referencia) throws ParseException {
        final SimpleDateFormat df = new SimpleDateFormat("yyyyMM");
        final SimpleDateFormat barCodeRef = new SimpleDateFormat("MMyyyy");
        codBarras = codBarras.replace("D", getDigitoVerificador(barCodeRef.format(df.parse(Integer.toString(referencia)))));
        codBarras = codBarras.replace("X", getDigitoVerificador(codBarras));
        String[] series = codBarras.split("-");
        for (int i = 0; i < series.length - 1; i++) {
            codBarras = codBarras.replaceFirst("H", getDigitoVerificador(series[i]));
        }
        return codBarras;
    }

    static String getDigitoVerificador(String cod) {
        String codStr = cod;
        int multiplyFactor = 2;
        int acumulator = 0;
        for (int i = codStr.length() - 1; i >= 0; i--) {
            Character currChar = codStr.charAt(i);
            if (Character.isDigit(currChar)) {
                int buffer = multiplyFactor * Integer.parseInt(String.valueOf(currChar));
                if (buffer > 9) {
                    acumulator += 1 + (buffer - 10);
                } else {
                    acumulator += buffer;
                }
                if (multiplyFactor == 2) {
                    multiplyFactor = 1;
                } else {
                    multiplyFactor = 2;
                }
            }
        }
        int mod = acumulator % 10;
        if (mod == 0) {
            return "0";
        } else {
            return String.valueOf(10 - mod);
        }
    }
}

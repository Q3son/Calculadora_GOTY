#!/usr/bin/perl

use strict;
use warnings;
use CGI qw(:standard);
use List::Util qw(min max);

print header('text/html; charset=UTF-8');
print start_html("Calculadora teamQ3son");

my $expresion = param('expresion') || '';
my $resultado = '';

if ($expresion) {
    if ($expresion =~ /^[\d\s+\-*\/\^().]+$/) {
        $resultado = evaluar_expresion($expresion);
    } else {
        $resultado = "Error: Caracteres no válidos en la expresión.";
    }
}

print <<HTML;
    <h1>Calculadora teamQ3son</h1>
    <form action="calculadora.pl" method="get">
        <div>
            <input type="text" id="pantalla" name="expresion" placeholder="Ingresa tu operación aquí" value="$expresion" readonly>
        </div>
        <div id="botones">
            <button type="button" onclick="agregarValor('7')">7</button>
            <button type="button" onclick="agregarValor('8')">8</button>
            <button type="button" onclick="agregarValor('9')">9</button>
            <button type="button" onclick="agregarValor('+')">+</button>
            <button type="button" onclick="agregarValor('4')">4</button>
            <button type="button" onclick="agregarValor('5')">5</button>
            <button type="button" onclick="agregarValor('6')">6</button>
            <button type="button" onclick="agregarValor('-')">-</button>
            <button type="button" onclick="agregarValor('1')">1</button>
            <button type="button" onclick="agregarValor('2')">2</button>
            <button type="button" onclick="agregarValor('3')">3</button>
            <button type="button" onclick="agregarValor('*')">*</button>
            <button type="button" onclick="agregarValor('0')">0</button>
            <button type="button" onclick="agregarValor('/')">/</button>
            <button type="button" onclick="agregarValor('^')">^</button>
            <button type="button" onclick="agregarValor('(')">(</button>
            <button type="button" onclick="agregarValor(')')">)</button>
            <button type="submit">Calcular</button>
            <button type="button" onclick="limpiar()">Limpiar</button>
            <button type="button" onclick="retroceder()">←</button>
        </div>
        <div id="mensajeError" style="color: red; margin-top: 10px;">Resultado: $resultado</div>
    </form>

    <script>
        function agregarValor(valor) {
            const pantalla = document.getElementById('pantalla');
            pantalla.value += valor;
        }

        function limpiar() {
            document.getElementById('pantalla').value = '';
        }

        function retroceder() {
            const pantalla = document.getElementById('pantalla');
            pantalla.value = pantalla.value.slice(0, -1);
        }
    </script>
HTML

print end_html;

sub evaluar_expresion {
    my ($expresion) = @_;

    # Separar la expresión en tokens (números y operadores)
    my @tokens = split(/(\D)/, $expresion);
    my @resultado;

    foreach my $token (@tokens) {
        if ($token =~ /^\s*$/) {
            next;  # Ignorar espacios
        }
        push @resultado, $token;  # Agregar tokens válidos
    }

    return calcular(\@resultado);
}

sub calcular {
    my ($tokens) = @_;

    # Manejo de operaciones en paréntesis
    while (my ($i) = grep { $tokens->[$_] eq '(' } (0..$#$tokens)) {
        my $inicio = $i;
        my $fin = $inicio + 1;

        # Encontrar el cierre del paréntesis
        my $nivel = 1;
        while ($nivel > 0 && $fin <= $#$tokens) {
            if ($tokens->[$fin] eq '(') {
                $nivel++;
            } elsif ($tokens->[$fin] eq ')') {
                $nivel--;
            }
            $fin++;
        }

        # Reemplazar la expresión entre paréntesis por su resultado
        my $subexp = [@$tokens[$inicio + 1 .. $fin - 2]];  # La subexpresión dentro de paréntesis
        my $subresultado = calcular($subexp);
        splice @$tokens, $inicio, $fin - $inicio, $subresultado;  # Reemplazar en la lista de tokens
    }

    # Manejo de operaciones de potencia
    while (my ($i) = grep { $tokens->[$_] eq '^' } (0..$#$tokens)) {
        my $base = $tokens->[$i - 1];
        my $exponente = $tokens->[$i + 1];
        my $resultado = $base ** $exponente;
        splice @$tokens, $i - 1, 3, $resultado;  # Reemplazar en la lista de tokens
    }

    # Manejo de multiplicación y división
    while (my ($i) = grep { $tokens->[$_] eq '*' || $tokens->[$_] eq '/' } (0..$#$tokens)) {
        my $izquierda = $tokens->[$i - 1];
        my $derecha = $tokens->[$i + 1];

        my $resultado;
        if ($tokens->[$i] eq '*') {
            $resultado = $izquierda * $derecha;
        } elsif ($tokens->[$i] eq '/') {
            $resultado = $derecha != 0 ? $izquierda / $derecha : 'Error: División por cero';
        }

        splice @$tokens, $i - 1, 3, $resultado;  # Reemplazar en la lista de tokens
    }

    # Manejo de suma y resta
    while (my ($i) = grep { $tokens->[$_] eq '+' || $tokens->[$_] eq '-' } (0..$#$tokens)) {
        my $izquierda = $tokens->[$i - 1];
        my $derecha = $tokens->[$i + 1];

        my $resultado;
        if ($tokens->[$i] eq '+') {
            $resultado = $izquierda + $derecha;
        } elsif ($tokens->[$i] eq '-') {
            $resultado = $izquierda - $derecha;
        }

        splice @$tokens, $i - 1, 3, $resultado;  # Reemplazar en la lista de tokens
    }

    return $tokens->[0];  # El resultado final debe ser el único valor en los tokens
}
#!/usr/bin/perl 

use strict;
use warnings;
use CGI qw(:standard);
use List::Util qw(min max);
use Scalar::Util qw(looks_like_number);

print header('text/html; charset=UTF-8');
my $expresion = param('expresion') || '';
my $resultado = '';

if ($expresion) {
    # Validar que la expresión contenga solo caracteres válidos
    if ($expresion =~ /^[\d\s+\-*\/\^().]+$/) {
        $resultado = evaluar_expresion($expresion);
    } else {
        $resultado = "Error: Caracteres no válidos en la expresión.";
    }
}

# Imprimir el formulario de la calculadora
print start_html("Calculadora teamQ3son");

print <<HTML;
    <h1>Calculadora teamQ3son</h1>
    <form method="GET" action="">
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
        <div id="resultado" style="margin-top: 20px; font-weight: bold;">
            Resultado: $resultado
        </div>
        <div id="mensajeError" style="color: red; margin-top: 10px;"></div>
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

    # Manejo de operaciones de potencia
    for (my $i = 0; $i < @$tokens; $i++) {
        if ($tokens->[$i] eq '^') {
            my $izquierda = $tokens->[$i - 1];
            my $derecha = $tokens->[$i + 1];

            if (looks_like_number($izquierda) && looks_like_number($derecha)) {
                my $resultado = $izquierda ** $derecha;  # Cálculo de potencia
                splice @$tokens, $i - 1, 3, $resultado;
                $i--;  # Retroceder un índice para manejar casos consecutivos
            }
        }
    }

    # Realizar las operaciones de multiplicación y división
    for my $operador ('*', '/') {
        for (my $i = 0; $i <= $#$tokens; $i++) {
            if ($tokens->[$i] eq $operador) {
                my $izquierda = $tokens->[$i - 1];
                my $derecha = $tokens->[$i + 1];

                if (looks_like_number($izquierda) && looks_like_number($derecha)) {
                    my $resultado = eval "$izquierda $operador $derecha";
                    splice @$tokens, $i - 1, 3, $resultado;
                    $i--;  # Retroceder un índice para manejar casos consecutivos
                }
            }
        }
    }

    # Realizar las operaciones de suma y resta
    for my $operador ('+', '-') {
        for (my $i = 0; $i <= $#$tokens; $i++) {
            if ($tokens->[$i] eq $operador) {
                my $izquierda = $tokens->[$i - 1];
                my $derecha = $tokens->[$i + 1];

                if (looks_like_number($izquierda) && looks_like_number($derecha)) {
                    my $resultado = eval "$izquierda $operador $derecha";
                    splice @$tokens, $i - 1, 3, $resultado;
                    $i--;  # Retroceder un índice para manejar casos consecutivos
                }
            }
        }
    }

    return $tokens->[0];  # El resultado final será el único elemento restante
}
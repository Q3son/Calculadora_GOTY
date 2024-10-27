#!/usr/bin/perl

use strict;
use warnings;
use CGI qw(:standard);
use List::Util qw(min max);
use Scalar::Util qw(looks_like_number);
use CGI::Carp qw(fatalsToBrowser);

my $cgi = CGI->new;
print $cgi->header('text/html');  # Envía la cabecera HTTP adecuada

my $expresion = $cgi->param('expresion') || '';
my $resultado = '';

# Procesa la expresión y calcula el resultado si hay una expresión válida
if ($expresion) {
    if ($expresion =~ /^[\d\s+\-*\/\^().]+$/) {
        $resultado = evaluar_expresion($expresion);
    } else {
        $resultado = "Error: Caracteres no válidos en la expresión.";
    }
}

# Imprime el resultado directamente en el cuerpo de la respuesta
print $resultado;

# Función para evaluar la expresión
sub evaluar_expresion {
    my ($expresion) = @_;

    my @tokens = split(/(\D)/, $expresion);
    my @resultado;

    foreach my $token (@tokens) {
        next if $token =~ /^\s*$/;
        push @resultado, $token;
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
                my $resultado = $izquierda ** $derecha;
                splice @$tokens, $i - 1, 3, $resultado;
                $i--;
            }
        }
    }

    # Multiplicación y división
    for my $operador ('*', '/') {
        for (my $i = 0; $i <= $#$tokens; $i++) {
            if ($tokens->[$i] eq $operador) {
                my $izquierda = $tokens->[$i - 1];
                my $derecha = $tokens->[$i + 1];

                if (looks_like_number($izquierda) && looks_like_number($derecha)) {
                    if ($operador eq '/' && $derecha == 0) {
                        return "Error: No se puede dividir entre 0.";
                    }
                    my $resultado = eval "$izquierda $operador $derecha";
                    splice @$tokens, $i - 1, 3, $resultado;
                    $i--;
                }
            }
        }
    }

    # Suma y resta
    for my $operador ('+', '-') {
        for (my $i = 0; $i <= $#$tokens; $i++) {
            if ($tokens->[$i] eq $operador) {
                my $izquierda = $tokens->[$i - 1];
                my $derecha = $tokens->[$i + 1];

                if (looks_like_number($izquierda) && looks_like_number($derecha)) {
                    my $resultado = eval "$izquierda $operador $derecha";
                    splice @$tokens, $i - 1, 3, $resultado;
                    $i--;
                }
            }
        }
    }

    return $tokens->[0];
}
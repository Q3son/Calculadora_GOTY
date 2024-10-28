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
    my @postfix = infija_a_postfija($expresion);
    return calcular(\@postfix);
}

# Convierte expresión infija a postfija utilizando el algoritmo de Shunting Yard
sub infija_a_postfija {
    my ($expresion) = @_;
    my @tokens = split(/(\D)/, $expresion);
    my @resultado;
    my @operadores;

    # Definir la precedencia de los operadores
    my %precedencia = (
        '+' => 1,
        '-' => 1,
        '*' => 2,
        '/' => 2,
        '^' => 3,
    );

    foreach my $token (@tokens) {
        next if $token =~ /^\s*$/;  # Ignorar espacios en blanco
        if (looks_like_number($token)) {
            push @resultado, $token;  # Si es un número, añadir a la salida
        } elsif ($token eq '(') {
            push @operadores, $token;  # Si es un paréntesis izquierdo, apilar
        } elsif ($token eq ')') {
            while (@operadores && $operadores[-1] ne '(') {
                push @resultado, pop @operadores;
            }
            pop @operadores;  # Eliminar '(' de la pila
        } else {
            # Manejar los operadores
            while (@operadores && exists $precedencia{$operadores[-1]} && 
                   $precedencia{$operadores[-1]} >= $precedencia{$token}) {
                push @resultado, pop @operadores;
            }
            push @operadores, $token;  # Apilar el operador actual
        }
    }

    # Vaciar la pila de operadores
    while (@operadores) {
        push @resultado, pop @operadores;
    }

    return @resultado;
}

sub calcular {
    my ($tokens) = @_;
    my @pila;

    foreach my $token (@$tokens) {
        if (looks_like_number($token)) {
            push @pila, $token;  # Si es un número, apilar
        } else {
            my $derecha = pop @pila;
            my $izquierda = pop @pila;

            if ($token eq '^') {
                push @pila, $izquierda ** $derecha;
            } elsif ($token eq '/') {
                return "Error: No se puede dividir entre 0." if $derecha == 0;
                push @pila, $izquierda / $derecha;
            } elsif ($token eq '*') {
                push @pila, $izquierda * $derecha;
            } elsif ($token eq '-') {
                push @pila, $izquierda - $derecha;
            } elsif ($token eq '+') {
                push @pila, $izquierda + $derecha;
            }
        }
    }

    return $pila[0];  # El resultado final estará en la cima de la pila
}
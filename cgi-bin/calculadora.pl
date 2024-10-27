#!/usr/bin/perl
use utf8;                              # Permite el uso de caracteres UTF-8
use strict;                           # Habilita restricciones de declaración
use warnings;                         # Activa advertencias sobre posibles errores
use CGI qw(:standard);                # Importa la biblioteca CGI
use URI::Escape;                      # Permite la codificación de URI
use List::Util qw(min max);          # Importa min y max desde List::Util

# Crear un nuevo objeto CGI
my $cgi = CGI->new;

# Imprimir cabeceras HTTP
print $cgi->header('text/html;charset=UTF-8');

# Capturar la expresión enviada desde el formulario
my $expresion = $cgi->param('expresion');

# Inicializar la variable resultado
my $resultado;

# Validar la expresión usando expresiones regulares
if ($expresion =~ /^[\d\s+\-*\/\^().]+$/) {
    
    # Evaluar la expresión
    eval {
        $resultado = eval($expresion);
        1;  # Retornar verdadero si no hay errores
    } or do {
        print $cgi->p("Error en la evaluación de la expresión: $@");
        exit;
    };
} else {
    print $cgi->p("Expresión inválida. Por favor, utiliza números y operadores válidos.");
}
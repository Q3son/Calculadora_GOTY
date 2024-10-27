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

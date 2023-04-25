#!/bin/bash

# text2audio - text to audio convert utilitity.
#
# Copyright (C) 2014-2018 Joel Barrios Dueñas
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

# Instalar festival, hispavoces-pal-diphone e hispavoces-sfl-diphone.

ARCHIVO=$1
AUDIO=$(echo ${ARCHIVO} |sed -e 's,.txt,,')

# Validamos que se proporcione un argumento.
if [ $# -eq 0 ]; then
    echo "* Se requiere 1 archivo de texto como argumento. *"
    echo "    Uso: $0 archivo-de-texto.txt"
    exit 1
fi

# Validamos que sea un archivo de texto simple.
TIPO=$(file --brief --mime-type ${ARCHIVO})
if [ ${TIPO} != 'text/plain' ] ; then
    echo "* No es un archivo de texto simple. *"
    exit 1
fi

function reproducir {
    echo -e "¿Desea escucharlo? (S/n) [s]"
    read ok &&
    echo $ok &&
    if  [[  $ok == "n"  ]]  ||  [[  $ok == "N"  ]]  ; then
        echo "Reproducción cancelada."
        exit ;
    else
        ogg123 -q ${AUDIO}.ogg
    fi
}

# TODO: Opciones de Voz.
#  Femenina:
#    voice_JuntaDeAndalucia_es_sf_diphone
#  Masculina:
#    voice_JuntaDeAndalucia_es_pa_diphone

#     echo $1 | iconv -f utf-8 -t iso-8859-1 | text2wave > $2

cat ${ARCHIVO} | \
    iconv -f utf-8 -t iso-8859-1 |
    text2wave \
    -eval '(voice_JuntaDeAndalucia_es_pa_diphone)' \
    > ${AUDIO}-tmp.wav && \
sox ${AUDIO}-tmp.wav ${AUDIO}.wav sinc 0k-5k && \
rm -f ${AUDIO}-tmp.wav && \
lame --quiet -b 320 -h ${AUDIO}.wav ${AUDIO}.mp3 && \
oggenc -Q -q 8 -o ${AUDIO}.ogg ${AUDIO}.wav && \
echo -e "\nSe produjeron dos archivos de audio:" && \
du -sh ${AUDIO}.mp3 ${AUDIO}.ogg && \
echo -e "\n" && \
reproducir

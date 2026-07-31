// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';

Future mostrarMisDeclaraciones(BuildContext context) async {
  const Color azul = Color(0xFF1B3A6B);
  const Color verde = Color(0xFF0F6E56);
  const Color verdeFondo = Color(0xFFE1F5EE);
  const Color crema = Color(0xFFFAFAF8);
  const Color textoSec = Color(0xFF6B7280);
  const Color borde = Color(0xFFE5E7EB);

  String euro(double n) {
    final abs = n.abs();
    final partes = abs.toStringAsFixed(2).split('.');
    final entero = partes[0];
    final buffer = StringBuffer();
    for (int i = 0; i < entero.length; i++) {
      if (i > 0 && (entero.length - i) % 3 == 0) buffer.write('.');
      buffer.write(entero[i]);
    }
    return '${buffer.toString()},${partes[1]} €';
  }

  String fecha(int ms) {
    if (ms == 0) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  // Leer las declaraciones
  final json = await leerDeclaraciones();
  Map<String, dynamic> data;
  try {
    data = jsonDecode(json);
  } catch (e) {
    data = {'error': true, 'mensaje': 'No se pudieron leer'};
  }

  final List declaraciones =
      (data['error'] != true) ? (data['declaraciones'] ?? []) : [];

  await showDialog(
    context: context,
    builder: (c) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(maxWidth: 460, maxHeight: 640),
        decoration: BoxDecoration(
          color: crema,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cabecera
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: azul,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mis declaraciones',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  InkWell(
                    onTap: () => Navigator.of(c).pop(),
                    child: Icon(Icons.close, color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),
            // Lista
            Flexible(
              child: declaraciones.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_open, size: 40, color: textoSec),
                          SizedBox(height: 12),
                          Text('Aún no tienes declaraciones guardadas',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: textoSec)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.all(14),
                      itemCount: declaraciones.length,
                      itemBuilder: (context, i) {
                        final d = declaraciones[i];
                        final result = (d['result'] ?? 0).toDouble();
                        final aDevolver = d['toRefund'] == true;
                        final idDecl = d['id']?.toString() ?? '';
                        return InkWell(
                          onTap: () async {
                            Navigator.of(c).pop();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (cc) => Center(
                                child: CircularProgressIndicator(color: azul),
                              ),
                            );
                            final resultadoJson =
                                await abrirDeclaracion(idDecl);
                            Navigator.of(context, rootNavigator: true).pop();
                            await mostrarInforme(context, resultadoJson);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 10),
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: borde, width: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Declaración ${d['year']}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: azul)),
                                    SizedBox(height: 4),
                                    Text(fecha(d['createdAt'] ?? 0),
                                        style: TextStyle(
                                            fontSize: 12, color: textoSec)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(euro(result),
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: azul)),
                                        SizedBox(height: 4),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: aDevolver
                                                ? verdeFondo
                                                : Color(0xFFFAEEDA),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                              aDevolver
                                                  ? 'A devolver'
                                                  : 'A pagar',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: aDevolver
                                                      ? verde
                                                      : Color(0xFF854F0B))),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.chevron_right,
                                        color: textoSec, size: 20),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}

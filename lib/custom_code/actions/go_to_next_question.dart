// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/app_state.dart';

Future<bool> goToNextQuestion() async {
  final visibles = FFAppState().visibleQuestions;
  final currentId = FFAppState().currentQuestionId;

  final currentIndex = visibles.indexWhere((q) => q.id == currentId);
  if (currentIndex == -1) return false;

  // Buscar la siguiente pregunta que deba mostrarse
  int nextIndex = currentIndex + 1;
  while (nextIndex < visibles.length) {
    final q = visibles[nextIndex];
    if (q.conditionField.isEmpty) break; // sin condición: mostrar
    final answered = await getAnswer(q.conditionField);
    if (answered == q.conditionValue) break; // condición cumplida: mostrar
    nextIndex++; // no se cumple: saltar
  }

  // No hay más preguntas válidas: fin
  if (nextIndex >= visibles.length) {
    return false;
  }

  final next = visibles[nextIndex];

  FFAppState().update(() {
    FFAppState().navigationHistory = [
      ...FFAppState().navigationHistory,
      currentId,
    ];
    FFAppState().currentQuestionId = next.id;
    FFAppState().currentModule = next.module;
  });

  return true;
}

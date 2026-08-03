// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import '/app_state.dart';

Future showInterviewDialog(BuildContext context) async {
  const Color primaryColor = Color(0xFF1B3A6B);
  const Color secondaryColor = Color(0xFF7BA9D0);
  const Color accentGold = Color(0xFFC9A961);
  const Color bgCream = Color(0xFFFAFAF8);
  const Color textPrimary = Color(0xFF2C3E50);
  const Color textSecondary = Color(0xFF6B7280);
  const Color borderColor = Color(0xFFE5E7EB);

  String? selectedOption;
  Set<String> multiSelected = {};
  DateTime? selectedDate;
  final TextEditingController textController = TextEditingController();
  bool showHelp = false;
  String? idPrecargado;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final visibles = FFAppState().visibleQuestions;
          final currentId = FFAppState().currentQuestionId;
          final idx = visibles.indexWhere((q) => q.id == currentId);
          if (idx == -1) {
            return Dialog(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No hay preguntas cargadas.'),
              ),
            );
          }
          final question = visibles[idx];

          // Precargar la respuesta guardada al mostrar una pregunta nueva
          if (idPrecargado != question.id) {
            idPrecargado = question.id;
            () async {
              final guardada = await getAnswer(question.id);
              if (guardada != null && guardada.toString().isNotEmpty) {
                final valor = guardada.toString();
                switch (question.controlType) {
                  case 'yesNo':
                  case 'singleSelect':
                  case 'dropdown':
                    selectedOption = valor;
                    break;
                  case 'multiSelect':
                    multiSelected = valor.split(',').toSet();
                    break;
                  case 'date':
                    try {
                      final p = valor.split('-');
                      selectedDate = DateTime(
                          int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
                    } catch (e) {}
                    break;
                  case 'integer':
                  case 'amount':
                  case 'text':
                    textController.text = valor;
                    break;
                }
                setState(() {});
              }
            }();
          }
          final hasPrevious = FFAppState().navigationHistory.isNotEmpty;
          final isLast = idx >= visibles.length - 1;
          final activeModules = FFAppState().activeModules;
          final currentModuleIdx = activeModules.indexOf(question.module);

          Widget controlWidget;
          switch (question.controlType) {
            case 'yesNo':
              controlWidget = Row(
                children: [
                  for (final opt in ['Sí', 'No']) ...[
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => selectedOption = opt),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: selectedOption == opt
                                ? secondaryColor.withOpacity(0.15)
                                : Colors.white,
                            border: Border.all(
                              color: selectedOption == opt
                                  ? primaryColor
                                  : borderColor,
                              width: selectedOption == opt ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(opt,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary)),
                          ),
                        ),
                      ),
                    ),
                    if (opt == 'Sí') SizedBox(width: 12),
                  ],
                ],
              );
              break;

            case 'integer':
              controlWidget = TextField(
                controller: textController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 16, color: textPrimary),
                decoration: _inputDecoration(
                    'Introduce un número', borderColor, primaryColor),
              );
              break;

            case 'amount':
              controlWidget = TextField(
                controller: textController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(fontSize: 16, color: textPrimary),
                decoration: _inputDecoration('0,00', borderColor, primaryColor)
                    .copyWith(suffixText: '€'),
              );
              break;

            case 'singleSelect':
              controlWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: question.options.map((opt) {
                  final isSelected = selectedOption == opt;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => setState(() => selectedOption = opt),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? secondaryColor.withOpacity(0.15)
                              : Colors.white,
                          border: Border.all(
                            color: isSelected ? primaryColor : borderColor,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              size: 18,
                              color: isSelected ? primaryColor : secondaryColor,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(opt,
                                  style: TextStyle(
                                      fontSize: 14, color: textPrimary)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
              break;

            case 'multiSelect':
              controlWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: question.options.map((opt) {
                  final isSelected = multiSelected.contains(opt);
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => setState(() {
                        if (isSelected) {
                          multiSelected.remove(opt);
                        } else {
                          multiSelected.add(opt);
                        }
                      }),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? secondaryColor.withOpacity(0.15)
                              : Colors.white,
                          border: Border.all(
                            color: isSelected ? primaryColor : borderColor,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 18,
                              color: isSelected ? primaryColor : secondaryColor,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(opt,
                                  style: TextStyle(
                                      fontSize: 14, color: textPrimary)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
              break;

            case 'date':
              controlWidget = InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate ?? DateTime(1990),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 18, color: secondaryColor),
                      SizedBox(width: 10),
                      Text(
                        selectedDate == null
                            ? 'Selecciona una fecha'
                            : '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}',
                        style: TextStyle(
                            fontSize: 15,
                            color: selectedDate == null
                                ? textSecondary
                                : textPrimary),
                      ),
                    ],
                  ),
                ),
              );
              break;

            case 'text':
              controlWidget = TextField(
                controller: textController,
                style: TextStyle(fontSize: 16, color: textPrimary),
                decoration:
                    _inputDecoration('Escribe aquí', borderColor, primaryColor),
              );
              break;

            case 'dropdown':
              controlWidget = Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: selectedOption != null ? primaryColor : borderColor,
                    width: selectedOption != null ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  value: (selectedOption != null &&
                          question.options.contains(selectedOption))
                      ? selectedOption
                      : null,
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  underline: SizedBox(),
                  hint: Text('Selecciona una opción',
                      style: TextStyle(color: textSecondary)),
                  style: TextStyle(fontSize: 15, color: textPrimary),
                  items: question.options.map((opt) {
                    return DropdownMenuItem<String>(
                      value: opt,
                      child: Text(opt, style: TextStyle(color: textPrimary)),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedOption = v;
                    });
                  },
                ),
              );
              break;
            case 'inmuebles':
              controlWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: secondaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: secondaryColor),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.home_work_outlined,
                            size: 20, color: primaryColor),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Añade aquí todos tus inmuebles: los que tienes alquilados y las segundas viviendas a tu disposición. No incluyas tu vivienda habitual.',
                            style: TextStyle(
                                fontSize: 14, color: textPrimary, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      await gestionarInmuebles(context);
                      setState(() {});
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_home_outlined,
                              size: 20, color: Colors.white),
                          SizedBox(width: 10),
                          Text('Gestionar mis inmuebles',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
              break;
            case 'info':
              controlWidget = Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: secondaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: secondaryColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 20, color: primaryColor),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question.clarification.isNotEmpty
                            ? question.clarification
                            : 'Información',
                        style: TextStyle(
                            fontSize: 14, color: textPrimary, height: 1.4),
                      ),
                    ),
                  ],
                ),
              );
              break;

            default:
              controlWidget = Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Control "${question.controlType}" no reconocido.',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                ),
              );
          }

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(24),
            child: Container(
              width: 600,
              constraints: BoxConstraints(maxHeight: 720),
              decoration: BoxDecoration(
                color: bgCream,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Color(0x1A0F172A),
                      blurRadius: 24,
                      offset: Offset(0, 8)),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.assignment_outlined,
                                  size: 20, color: Colors.white),
                              SizedBox(width: 10),
                              Text('Módulo ${question.module}',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ],
                          ),
                          InkWell(
                            onTap: () async {
                              final salir = await showDialog<bool>(
                                context: context,
                                builder: (dc) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: Container(
                                    constraints: BoxConstraints(maxWidth: 360),
                                    padding: EdgeInsets.all(22),
                                    decoration: BoxDecoration(
                                      color: bgCream,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('¿Salir del cuestionario?',
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                                color: primaryColor)),
                                        SizedBox(height: 6),
                                        Text(
                                            'Tu progreso se guarda. Podrás continuar más tarde desde donde lo dejaste.',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: textSecondary)),
                                        SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextButton(
                                                onPressed: () =>
                                                    Navigator.of(dc).pop(false),
                                                style: TextButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 13),
                                                  side: BorderSide(
                                                      color: primaryColor),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                ),
                                                child: Text('Seguir',
                                                    style: TextStyle(
                                                        color: primaryColor,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: TextButton(
                                                onPressed: () =>
                                                    Navigator.of(dc).pop(true),
                                                style: TextButton.styleFrom(
                                                  backgroundColor: primaryColor,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 13),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                ),
                                                child: Text('Salir',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                              if (salir == true) {
                                Navigator.of(ctx, rootNavigator: true).pop();
                              }
                            },
                            child: Icon(Icons.close,
                                size: 22, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 2, color: accentGold),
                    if (activeModules.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Row(
                          children: [
                            for (int i = 0; i < activeModules.length; i++) ...[
                              Expanded(
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: i <= currentModuleIdx
                                        ? primaryColor
                                        : borderColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              if (i < activeModules.length - 1)
                                SizedBox(width: 4),
                            ],
                          ],
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(question.questionText,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                  height: 1.3)),
                          if (question.clarification.isNotEmpty &&
                              question.controlType != 'info') ...[
                            SizedBox(height: 8),
                            Text(question.clarification,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: textSecondary,
                                    height: 1.4)),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: controlWidget,
                    ),
                    if (question.shortHelp.isNotEmpty) ...[
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => setState(() => showHelp = !showHelp),
                              child: Row(
                                children: [
                                  Icon(Icons.help_outline,
                                      size: 16, color: primaryColor),
                                  SizedBox(width: 6),
                                  Text('¿Por qué se pregunta esto?',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: primaryColor,
                                          fontWeight: FontWeight.w600)),
                                  Icon(
                                      showHelp
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      size: 18,
                                      color: primaryColor),
                                ],
                              ),
                            ),
                            if (showHelp) ...[
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Text(question.shortHelp,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: textSecondary,
                                        height: 1.5)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 28),
                    Padding(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Row(
                        children: [
                          if (hasPrevious)
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  await goToPreviousQuestion();
                                  selectedOption = null;
                                  multiSelected = {};
                                  selectedDate = null;
                                  textController.clear();
                                  showHelp = false;
                                  setState(() {});
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: primaryColor),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text('Atrás',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: primaryColor)),
                                  ),
                                ),
                              ),
                            ),
                          if (hasPrevious) SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: InkWell(
                              onTap: () async {
                                String answerValue = '';
                                switch (question.controlType) {
                                  case 'yesNo':
                                  case 'singleSelect':
                                  case 'dropdown':
                                    answerValue = selectedOption ?? '';
                                    break;
                                  case 'multiSelect':
                                    answerValue = multiSelected.join(',');
                                    break;
                                  case 'date':
                                    answerValue = selectedDate == null
                                        ? ''
                                        : '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}';
                                    break;
                                  case 'integer':
                                  case 'amount':
                                  case 'text':
                                    answerValue = textController.text;
                                    break;
                                }
// La pantalla de inmuebles no guarda un valor
                                // de texto; los inmuebles se guardan aparte.
                                if (question.controlType == 'inmuebles') {
                                  answerValue = 'ok';
                                }
                                // ← AQUÍ el bloque nuevo de validación
                                if (question.required &&
                                    answerValue.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Por favor, responde antes de continuar'),
                                      backgroundColor: Color(0xFFBA7517),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }

                                await saveAnswer(question.id, answerValue);

                                final advanced = await goToNextQuestion();
                                if (!advanced) {
                                  await finishInterview();

                                  // Cerrar el diálogo de la entrevista
                                  Navigator.of(ctx, rootNavigator: true).pop();

                                  // Mostrar diálogo de "calculando" con reloj girando
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (c) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: Container(
                                        padding: EdgeInsets.all(28),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFAFAF8),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const _RelojDeArena(),
                                            SizedBox(height: 18),
                                            Text('Calculando tu declaración...',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Color(0xFF2C3E50),
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );

                                  // Llamar al cálculo
                                  final resultadoJson =
                                      await calcularDeclaracion();

                                  // Cerrar el diálogo de "calculando"
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();

                                  // Mostrar el informe con el desglose
                                  await mostrarInforme(context, resultadoJson);
                                  return;
                                }
                                selectedOption = null;
                                multiSelected = {};
                                selectedDate = null;
                                textController.clear();
                                showHelp = false;
                                setState(() {});
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                      isLast ? 'Finalizar' : 'Continuar',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );

  textController.dispose();
}

InputDecoration _inputDecoration(String hint, Color border, Color focus) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: focus, width: 2),
    ),
  );
}

class _RelojDeArena extends StatefulWidget {
  const _RelojDeArena();

  @override
  State<_RelojDeArena> createState() => _RelojDeArenaState();
}

class _RelojDeArenaState extends State<_RelojDeArena>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child:
          const Icon(Icons.hourglass_top, size: 44, color: Color(0xFF1B3A6B)),
    );
  }
}

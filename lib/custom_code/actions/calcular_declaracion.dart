// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> calcularDeclaracion() async {
  final prefs = await SharedPreferences.getInstance();

  String getA(String id) => prefs.getString('answer_$id') ?? '';

  double num(String id) {
    final raw = getA(id).replaceAll('.', '').replaceAll(',', '.').trim();
    return double.tryParse(raw) ?? 0.0;
  }

  int intv(String id) => num(id).round();

  bool si(String id) => getA(id).trim().toLowerCase() == 'sí';

  String comunidad() {
    final c = getA('m01_comunidad').trim();
    const mapa = {
      'Andalucía': 'andalucia',
      'Aragón': 'aragon',
      'Asturias': 'asturias',
      'Canarias': 'canarias',
      'Cantabria': 'cantabria',
      'Castilla-La Mancha': 'castilla_la_mancha',
      'Castilla y León': 'castilla_leon',
      'Cataluña': 'cataluna',
      'Comunidad Valenciana': 'valencia',
      'Extremadura': 'extremadura',
      'Galicia': 'galicia',
      'Islas Baleares': 'baleares',
      'La Rioja': 'rioja',
      'Madrid': 'madrid',
      'Murcia': 'murcia',
    };
    return mapa[c] ?? 'referencia';
  }

  int gradoDiscapacidad() {
    final g = getA('m04_grado_discapacidad');
    if (g.contains('65')) return 65;
    if (g.contains('33')) return 33;
    return 0;
  }

  int edad = 0;
  final fechaNac = getA('m01_birth_date');
  if (fechaNac.isNotEmpty) {
    try {
      final partes = fechaNac.split('-');
      final anioNac = int.parse(partes[0]);
      final ahora = DateTime.now();
      edad = ahora.year - anioNac;
    } catch (e) {
      edad = 0;
    }
  }

  String famNumerosa() {
    final v = getA('m13_familia_numerosa').toLowerCase();
    if (v.contains('especial')) return 'especial';
    if (v.contains('general')) return 'general';
    return '';
  }

// Leer la lista de inmuebles (guardada por gestionarInmuebles)
  List<dynamic> inmuebles = [];
  final inmueblesRaw = prefs.getString('answer_inmuebles_json');
  if (inmueblesRaw != null && inmueblesRaw.isNotEmpty) {
    try {
      final decoded = jsonDecode(inmueblesRaw);
      if (decoded is List) inmuebles = decoded;
    } catch (e) {
      inmuebles = [];
    }
  }
  final datos = {
    'ingreso_integro_trabajo': num('m02_gross_income'),
    'retribucion_especie': num('m02_especie'),
    'seguridad_social': num('m02_social_security'),
    'retenciones': num('m02_withholdings'),
    'edad': edad,
    'tiene_trabajo_extranjero': si('m02_foreign_work'),
    'importe_exento_7p': num('m02_7p_importe'),
    'dias_extranjero': intv('m02_foreign_days'),
    'num_hijos': intv('m03_num_hijos'),
    'hijos_menores_3': intv('m03_hijos_menores_3'),
    'grado_discapacidad': gradoDiscapacidad(),
    'comunidad': comunidad(),
    'dividendos': num('m05_dividendos'),
    'intereses': num('m05_intereses'),
    'retenciones_capital': num('m05_retenciones_capital'),
    'perdidas_pendientes_anteriores': num('m06_perdidas_pendientes'),
    'aportacion_empleo_trabajador': num('m12_aportacion_trabajador'),
    'contribucion_empresa': num('m12_contribucion_empresa'),
    'donativos': num('m11_importe_donativos'),
    'hijos_nacidos_ejercicio': intv('m13_hijos_nacidos'),
    'es_joven_alquiler': si('m13_es_joven_alquiler'),
    'alquiler_pagado_anual': num('m13_alquiler_pagado'),
    'gastos_escolaridad': num('m13_gastos_escolaridad'),
    'gastos_idiomas': num('m13_gastos_idiomas'),
    'gastos_vestuario_escolar': num('m13_gastos_vestuario'),
    'cuotas_empleada_hogar': num('m13_cuotas_hogar'),
    'ascendientes_a_cargo': intv('m04_num_ascendientes'),
    'tipo_familia_numerosa': famNumerosa(),
    'gastos_guarderia': num('m13ar_gastos_guarderia'),
    'gastos_clases_apoyo': num('m13ar_clases_apoyo'),
    'personas_dependientes': intv('m04_num_ascendientes'),
    'inversion_nuevas_entidades': num('m13_inversion_nuevas'),
    'inversion_tipo_especial': si('m13_inversion_especial'),
    'es_familia_monoparental': si('m13_monoparental'),
    'contribuyente_con_discapacidad': si('m04_discapacidad_propia'),
    'es_viudo_reciente': si('m13_es_viudo'),
    'tiene_hijos_a_cargo': si('m03_tiene_hijos'),
    'gastos_rehabilitacion_vivienda': num('m13_gastos_rehabilitacion'),
    'hijos_3_a_5_anos': intv('m13_hijos_3_5'),
    'hijos_material_escolar': intv('m13_material_escolar'),
    'gasto_abonos_culturales': num('m13_abonos_culturales'),
    'adopciones_ejercicio': intv('m13_adopciones'),
    'adopcion_internacional_cyl': si('m13_adopcion_internacional'),
    'inmuebles': inmuebles,
    'retenciones_ganancias': num('m06_retenciones_ganancias'),
    'trabajador_activo': si('m04_trabajador_activo'),
    'movilidad_geografica': si('m04_movilidad_geografica'),
    'anualidades_alimentos_hijos': num('m03_anualidades_alimentos'),
    // Cuota sindical
    'cuota_sindical': num('m02_union_fee'),
    // Fondos sumados a las ganancias/pérdidas (CAMBIAR las líneas existentes)
    'ganancias_patrimoniales':
        num('m06_ganancias') + num('m07_ganancia_fondos'),
    'perdidas_patrimoniales': num('m06_perdidas') + num('m07_perdida_fondos'),
    // Venta de inmuebles (M08)
    'venta_inmueble_transmision': num('m08_valor_venta'),
    'venta_inmueble_adquisicion': num('m08_valor_compra'),
    'reinversion_vivienda': si('m08_reinversion'),
    'importe_reinvertido': num('m08_importe_reinvertido'),
    'mayor_65_vivienda_habitual': (edad >= 65 && si('m08_era_habitual')),
    // Vivienda habitual / hipoteca (M10)
    'vivienda_habitual_anterior_2013': si('m10_hipoteca_anterior_2013'),
    'pago_hipoteca_anual': num('m10_pago_hipoteca'),
    // Doble imposición internacional (M15)
    'deduccion_doble_imposicion_int': num('m15_importe_retenido'),
  };

  const base = 'https://mirenta-api-976371529191.europe-west1.run.app';

  try {
    // 1. Cálculo individual (declaración principal)
    final resp = await http.post(
      Uri.parse('$base/calcular/irpf'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datos),
    );
    if (resp.statusCode != 200) {
      return '{"error": true, "mensaje": "Error ${resp.statusCode}"}';
    }

    // ¿Casado y quiere comparar con la conjunta?
    final casado = getA('m01_civil_status').trim().toLowerCase() == 'casado/a';
    final quiereComparar = si('m01_conjunta_posible');

    if (!casado || !quiereComparar) {
      // Sin comparación: devolvemos el resultado individual tal cual
      return resp.body;
    }

    // 2. Datos del cónyuge (módulo M14)
    final conyuge = {
      'ingreso_integro_trabajo': num('m14_conyuge_trabajo'),
      'seguridad_social': num('m14_conyuge_ss'),
      'retenciones': num('m14_conyuge_retenciones'),
      'dividendos': num('m14_conyuge_capital'),
      'edad': 0,
    };

    // 3. Datos de la unidad familiar
    final unidad = {
      'comunidad': comunidad(),
      'num_hijos': intv('m03_num_hijos'),
      'hijos_menores_3': intv('m03_hijos_menores_3'),
    };

    // 4. Llamada al comparador individual vs conjunta
    final declaranteA = {
      'ingreso_integro_trabajo': num('m02_gross_income'),
      'seguridad_social': num('m02_social_security'),
      'retenciones': num('m02_withholdings'),
      'dividendos': num('m05_dividendos'),
      'intereses': num('m05_intereses'),
      'ganancias_patrimoniales': num('m06_ganancias'),
      'perdidas_patrimoniales': num('m06_perdidas'),
      'edad': edad,
    };

    final respComp = await http.post(
      Uri.parse('$base/calcular/comparar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'declarante_a': declaranteA,
        'declarante_b': conyuge,
        'unidad': unidad,
      }),
    );

    // 5. Combinar: resultado individual + comparación en un solo JSON
    final resultadoIndividual = jsonDecode(resp.body);
    if (respComp.statusCode == 200) {
      resultadoIndividual['comparacion'] = jsonDecode(respComp.body);
    }
    return jsonEncode(resultadoIndividual);
  } catch (e) {
    return '{"error": true, "mensaje": "$e"}';
  }
}

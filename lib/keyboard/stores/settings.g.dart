// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SettingsStore on AbstractSettingsStore, Store {
  late final _$longPressDurationAtom =
      Atom(name: 'AbstractSettingsStore.longPressDuration', context: context);

  @override
  Duration get longPressDuration {
    _$longPressDurationAtom.reportRead();
    return super.longPressDuration;
  }

  @override
  set longPressDuration(Duration value) {
    _$longPressDurationAtom.reportWrite(value, super.longPressDuration, () {
      super.longPressDuration = value;
    });
  }

  late final _$repeatIntervalAtom =
      Atom(name: 'AbstractSettingsStore.repeatInterval', context: context);

  @override
  Duration get repeatInterval {
    _$repeatIntervalAtom.reportRead();
    return super.repeatInterval;
  }

  @override
  set repeatInterval(Duration value) {
    _$repeatIntervalAtom.reportWrite(value, super.repeatInterval, () {
      super.repeatInterval = value;
    });
  }

  @override
  String toString() {
    return '''
longPressDuration: ${longPressDuration},
repeatInterval: ${repeatInterval}
    ''';
  }
}

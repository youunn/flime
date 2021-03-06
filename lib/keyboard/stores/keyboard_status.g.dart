// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyboard_status.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$KeyboardStatus on AbstractKeyboardStatus, Store {
  late final _$modifierStateAtom =
      Atom(name: 'AbstractKeyboardStatus.modifierState', context: context);

  @override
  int get modifierState {
    _$modifierStateAtom.reportRead();
    return super.modifierState;
  }

  @override
  set modifierState(int value) {
    _$modifierStateAtom.reportWrite(value, super.modifierState, () {
      super.modifierState = value;
    });
  }

  late final _$isComposingAtom =
      Atom(name: 'AbstractKeyboardStatus.isComposing', context: context);

  @override
  bool get isComposing {
    _$isComposingAtom.reportRead();
    return super.isComposing;
  }

  @override
  set isComposing(bool value) {
    _$isComposingAtom.reportWrite(value, super.isComposing, () {
      super.isComposing = value;
    });
  }

  late final _$isAsciiModeAtom =
      Atom(name: 'AbstractKeyboardStatus.isAsciiMode', context: context);

  @override
  bool get isAsciiMode {
    _$isAsciiModeAtom.reportRead();
    return super.isAsciiMode;
  }

  @override
  set isAsciiMode(bool value) {
    _$isAsciiModeAtom.reportWrite(value, super.isAsciiMode, () {
      super.isAsciiMode = value;
    });
  }

  late final _$schemaIdAtom =
      Atom(name: 'AbstractKeyboardStatus.schemaId', context: context);

  @override
  String? get schemaId {
    _$schemaIdAtom.reportRead();
    return super.schemaId;
  }

  @override
  set schemaId(String? value) {
    _$schemaIdAtom.reportWrite(value, super.schemaId, () {
      super.schemaId = value;
    });
  }

  late final _$schemaNameAtom =
      Atom(name: 'AbstractKeyboardStatus.schemaName', context: context);

  @override
  String? get schemaName {
    _$schemaNameAtom.reportRead();
    return super.schemaName;
  }

  @override
  set schemaName(String? value) {
    _$schemaNameAtom.reportWrite(value, super.schemaName, () {
      super.schemaName = value;
    });
  }

  late final _$candidatesAtom =
      Atom(name: 'AbstractKeyboardStatus.candidates', context: context);

  @override
  List<String?> get candidates {
    _$candidatesAtom.reportRead();
    return super.candidates;
  }

  @override
  set candidates(List<String?> value) {
    _$candidatesAtom.reportWrite(value, super.candidates, () {
      super.candidates = value;
    });
  }

  late final _$commentsAtom =
      Atom(name: 'AbstractKeyboardStatus.comments', context: context);

  @override
  List<String?> get comments {
    _$commentsAtom.reportRead();
    return super.comments;
  }

  @override
  set comments(List<String?> value) {
    _$commentsAtom.reportWrite(value, super.comments, () {
      super.comments = value;
    });
  }

  late final _$preeditAtom =
      Atom(name: 'AbstractKeyboardStatus.preedit', context: context);

  @override
  String? get preedit {
    _$preeditAtom.reportRead();
    return super.preedit;
  }

  @override
  set preedit(String? value) {
    _$preeditAtom.reportWrite(value, super.preedit, () {
      super.preedit = value;
    });
  }

  late final _$previewAtom =
      Atom(name: 'AbstractKeyboardStatus.preview', context: context);

  @override
  String? get preview {
    _$previewAtom.reportRead();
    return super.preview;
  }

  @override
  set preview(String? value) {
    _$previewAtom.reportWrite(value, super.preview, () {
      super.preview = value;
    });
  }

  late final _$shiftLockAtom =
      Atom(name: 'AbstractKeyboardStatus.shiftLock', context: context);

  @override
  bool? get shiftLock {
    _$shiftLockAtom.reportRead();
    return super.shiftLock;
  }

  @override
  set shiftLock(bool? value) {
    _$shiftLockAtom.reportWrite(value, super.shiftLock, () {
      super.shiftLock = value;
    });
  }

  late final _$controlLockAtom =
      Atom(name: 'AbstractKeyboardStatus.controlLock', context: context);

  @override
  bool? get controlLock {
    _$controlLockAtom.reportRead();
    return super.controlLock;
  }

  @override
  set controlLock(bool? value) {
    _$controlLockAtom.reportWrite(value, super.controlLock, () {
      super.controlLock = value;
    });
  }

  late final _$metaLockAtom =
      Atom(name: 'AbstractKeyboardStatus.metaLock', context: context);

  @override
  bool? get metaLock {
    _$metaLockAtom.reportRead();
    return super.metaLock;
  }

  @override
  set metaLock(bool? value) {
    _$metaLockAtom.reportWrite(value, super.metaLock, () {
      super.metaLock = value;
    });
  }

  late final _$altLockAtom =
      Atom(name: 'AbstractKeyboardStatus.altLock', context: context);

  @override
  bool? get altLock {
    _$altLockAtom.reportRead();
    return super.altLock;
  }

  @override
  set altLock(bool? value) {
    _$altLockAtom.reportWrite(value, super.altLock, () {
      super.altLock = value;
    });
  }

  late final _$editorActionAtom =
      Atom(name: 'AbstractKeyboardStatus.editorAction', context: context);

  @override
  int get editorAction {
    _$editorActionAtom.reportRead();
    return super.editorAction;
  }

  @override
  set editorAction(int value) {
    _$editorActionAtom.reportWrite(value, super.editorAction, () {
      super.editorAction = value;
    });
  }

  late final _$AbstractKeyboardStatusActionController =
      ActionController(name: 'AbstractKeyboardStatus', context: context);

  @override
  bool setModifier(int mask, {required bool state}) {
    final _$actionInfo = _$AbstractKeyboardStatusActionController.startAction(
        name: 'AbstractKeyboardStatus.setModifier');
    try {
      return super.setModifier(mask, state: state);
    } finally {
      _$AbstractKeyboardStatusActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetModifier() {
    final _$actionInfo = _$AbstractKeyboardStatusActionController.startAction(
        name: 'AbstractKeyboardStatus.resetModifier');
    try {
      return super.resetModifier();
    } finally {
      _$AbstractKeyboardStatusActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
modifierState: ${modifierState},
isComposing: ${isComposing},
isAsciiMode: ${isAsciiMode},
schemaId: ${schemaId},
schemaName: ${schemaName},
candidates: ${candidates},
comments: ${comments},
preedit: ${preedit},
preview: ${preview},
shiftLock: ${shiftLock},
controlLock: ${controlLock},
metaLock: ${metaLock},
altLock: ${altLock},
editorAction: ${editorAction}
    ''';
  }
}

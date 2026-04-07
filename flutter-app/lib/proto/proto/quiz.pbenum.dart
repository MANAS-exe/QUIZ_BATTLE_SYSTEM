//
//  Generated code. Do not modify.
//  source: proto/quiz.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Difficulty extends $pb.ProtobufEnum {
  static const Difficulty DIFFICULTY_UNSPECIFIED = Difficulty._(0, _omitEnumNames ? '' : 'DIFFICULTY_UNSPECIFIED');
  static const Difficulty EASY = Difficulty._(1, _omitEnumNames ? '' : 'EASY');
  static const Difficulty MEDIUM = Difficulty._(2, _omitEnumNames ? '' : 'MEDIUM');
  static const Difficulty HARD = Difficulty._(3, _omitEnumNames ? '' : 'HARD');

  static const $core.List<Difficulty> values = <Difficulty> [
    DIFFICULTY_UNSPECIFIED,
    EASY,
    MEDIUM,
    HARD,
  ];

  static final $core.Map<$core.int, Difficulty> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Difficulty? valueOf($core.int value) => _byValue[value];

  const Difficulty._($core.int v, $core.String n) : super(v, n);
}

class MatchState extends $pb.ProtobufEnum {
  static const MatchState MATCH_STATE_UNSPECIFIED = MatchState._(0, _omitEnumNames ? '' : 'MATCH_STATE_UNSPECIFIED');
  static const MatchState WAITING = MatchState._(1, _omitEnumNames ? '' : 'WAITING');
  static const MatchState IN_PROGRESS = MatchState._(2, _omitEnumNames ? '' : 'IN_PROGRESS');
  static const MatchState FINISHED = MatchState._(3, _omitEnumNames ? '' : 'FINISHED');

  static const $core.List<MatchState> values = <MatchState> [
    MATCH_STATE_UNSPECIFIED,
    WAITING,
    IN_PROGRESS,
    FINISHED,
  ];

  static final $core.Map<$core.int, MatchState> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MatchState? valueOf($core.int value) => _byValue[value];

  const MatchState._($core.int v, $core.String n) : super(v, n);
}

class PlayerStatus extends $pb.ProtobufEnum {
  static const PlayerStatus PLAYER_STATUS_UNSPECIFIED = PlayerStatus._(0, _omitEnumNames ? '' : 'PLAYER_STATUS_UNSPECIFIED');
  static const PlayerStatus CONNECTED = PlayerStatus._(1, _omitEnumNames ? '' : 'CONNECTED');
  static const PlayerStatus DISCONNECTED = PlayerStatus._(2, _omitEnumNames ? '' : 'DISCONNECTED');
  static const PlayerStatus RECONNECTING = PlayerStatus._(3, _omitEnumNames ? '' : 'RECONNECTING');

  static const $core.List<PlayerStatus> values = <PlayerStatus> [
    PLAYER_STATUS_UNSPECIFIED,
    CONNECTED,
    DISCONNECTED,
    RECONNECTING,
  ];

  static final $core.Map<$core.int, PlayerStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static PlayerStatus? valueOf($core.int value) => _byValue[value];

  const PlayerStatus._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');

//
//  Generated code. Do not modify.
//  source: quiz.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'quiz.pbenum.dart';

export 'quiz.pbenum.dart';

class Player extends $pb.GeneratedMessage {
  factory Player({
    $core.String? userId,
    $core.String? username,
    $core.int? rating,
    PlayerStatus? status,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    if (username != null) {
      $result.username = username;
    }
    if (rating != null) {
      $result.rating = rating;
    }
    if (status != null) {
      $result.status = status;
    }
    return $result;
  }
  Player._() : super();
  factory Player.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Player.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Player', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'rating', $pb.PbFieldType.O3)
    ..e<PlayerStatus>(4, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: PlayerStatus.PLAYER_STATUS_UNSPECIFIED, valueOf: PlayerStatus.valueOf, enumValues: PlayerStatus.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Player clone() => Player()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Player copyWith(void Function(Player) updates) => super.copyWith((message) => updates(message as Player)) as Player;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Player create() => Player._();
  Player createEmptyInstance() => create();
  static $pb.PbList<Player> createRepeated() => $pb.PbList<Player>();
  @$core.pragma('dart2js:noInline')
  static Player getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Player>(create);
  static Player? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get username => $_getSZ(1);
  @$pb.TagNumber(2)
  set username($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUsername() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsername() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get rating => $_getIZ(2);
  @$pb.TagNumber(3)
  set rating($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRating() => $_has(2);
  @$pb.TagNumber(3)
  void clearRating() => clearField(3);

  @$pb.TagNumber(4)
  PlayerStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(PlayerStatus v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => clearField(4);
}

class Question extends $pb.GeneratedMessage {
  factory Question({
    $core.String? questionId,
    $core.String? text,
    $core.Iterable<$core.String>? options,
    Difficulty? difficulty,
    $core.String? topic,
    $core.int? timeLimitMs,
  }) {
    final $result = create();
    if (questionId != null) {
      $result.questionId = questionId;
    }
    if (text != null) {
      $result.text = text;
    }
    if (options != null) {
      $result.options.addAll(options);
    }
    if (difficulty != null) {
      $result.difficulty = difficulty;
    }
    if (topic != null) {
      $result.topic = topic;
    }
    if (timeLimitMs != null) {
      $result.timeLimitMs = timeLimitMs;
    }
    return $result;
  }
  Question._() : super();
  factory Question.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Question.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Question', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'questionId')
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..pPS(3, _omitFieldNames ? '' : 'options')
    ..e<Difficulty>(4, _omitFieldNames ? '' : 'difficulty', $pb.PbFieldType.OE, defaultOrMaker: Difficulty.DIFFICULTY_UNSPECIFIED, valueOf: Difficulty.valueOf, enumValues: Difficulty.values)
    ..aOS(5, _omitFieldNames ? '' : 'topic')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'timeLimitMs', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Question clone() => Question()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Question copyWith(void Function(Question) updates) => super.copyWith((message) => updates(message as Question)) as Question;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Question create() => Question._();
  Question createEmptyInstance() => create();
  static $pb.PbList<Question> createRepeated() => $pb.PbList<Question>();
  @$core.pragma('dart2js:noInline')
  static Question getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Question>(create);
  static Question? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get questionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set questionId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuestionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuestionId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.String> get options => $_getList(2);

  @$pb.TagNumber(4)
  Difficulty get difficulty => $_getN(3);
  @$pb.TagNumber(4)
  set difficulty(Difficulty v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasDifficulty() => $_has(3);
  @$pb.TagNumber(4)
  void clearDifficulty() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get topic => $_getSZ(4);
  @$pb.TagNumber(5)
  set topic($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTopic() => $_has(4);
  @$pb.TagNumber(5)
  void clearTopic() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get timeLimitMs => $_getIZ(5);
  @$pb.TagNumber(6)
  set timeLimitMs($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTimeLimitMs() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimeLimitMs() => clearField(6);
}

class PlayerScore extends $pb.GeneratedMessage {
  factory PlayerScore({
    $core.String? userId,
    $core.String? username,
    $core.int? score,
    $core.int? rank,
    $core.int? answersCorrect,
    $core.int? avgResponseMs,
    $core.bool? isConnected,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    if (username != null) {
      $result.username = username;
    }
    if (score != null) {
      $result.score = score;
    }
    if (rank != null) {
      $result.rank = rank;
    }
    if (answersCorrect != null) {
      $result.answersCorrect = answersCorrect;
    }
    if (avgResponseMs != null) {
      $result.avgResponseMs = avgResponseMs;
    }
    if (isConnected != null) {
      $result.isConnected = isConnected;
    }
    return $result;
  }
  PlayerScore._() : super();
  factory PlayerScore.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PlayerScore.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PlayerScore', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'score', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'rank', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'answersCorrect', $pb.PbFieldType.O3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'avgResponseMs', $pb.PbFieldType.O3)
    ..aOB(7, _omitFieldNames ? '' : 'isConnected')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PlayerScore clone() => PlayerScore()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PlayerScore copyWith(void Function(PlayerScore) updates) => super.copyWith((message) => updates(message as PlayerScore)) as PlayerScore;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PlayerScore create() => PlayerScore._();
  PlayerScore createEmptyInstance() => create();
  static $pb.PbList<PlayerScore> createRepeated() => $pb.PbList<PlayerScore>();
  @$core.pragma('dart2js:noInline')
  static PlayerScore getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PlayerScore>(create);
  static PlayerScore? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get username => $_getSZ(1);
  @$pb.TagNumber(2)
  set username($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUsername() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsername() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get score => $_getIZ(2);
  @$pb.TagNumber(3)
  set score($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasScore() => $_has(2);
  @$pb.TagNumber(3)
  void clearScore() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get rank => $_getIZ(3);
  @$pb.TagNumber(4)
  set rank($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRank() => $_has(3);
  @$pb.TagNumber(4)
  void clearRank() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get answersCorrect => $_getIZ(4);
  @$pb.TagNumber(5)
  set answersCorrect($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasAnswersCorrect() => $_has(4);
  @$pb.TagNumber(5)
  void clearAnswersCorrect() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get avgResponseMs => $_getIZ(5);
  @$pb.TagNumber(6)
  set avgResponseMs($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasAvgResponseMs() => $_has(5);
  @$pb.TagNumber(6)
  void clearAvgResponseMs() => clearField(6);

  @$pb.TagNumber(7)
  $core.bool get isConnected => $_getBF(6);
  @$pb.TagNumber(7)
  set isConnected($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasIsConnected() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsConnected() => clearField(7);
}

/// JoinMatchmaking
class JoinRequest extends $pb.GeneratedMessage {
  factory JoinRequest({
    $core.String? userId,
    $core.String? username,
    $core.int? rating,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    if (username != null) {
      $result.username = username;
    }
    if (rating != null) {
      $result.rating = rating;
    }
    return $result;
  }
  JoinRequest._() : super();
  factory JoinRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory JoinRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'JoinRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'rating', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  JoinRequest clone() => JoinRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  JoinRequest copyWith(void Function(JoinRequest) updates) => super.copyWith((message) => updates(message as JoinRequest)) as JoinRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinRequest create() => JoinRequest._();
  JoinRequest createEmptyInstance() => create();
  static $pb.PbList<JoinRequest> createRepeated() => $pb.PbList<JoinRequest>();
  @$core.pragma('dart2js:noInline')
  static JoinRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<JoinRequest>(create);
  static JoinRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get username => $_getSZ(1);
  @$pb.TagNumber(2)
  set username($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUsername() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsername() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get rating => $_getIZ(2);
  @$pb.TagNumber(3)
  set rating($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRating() => $_has(2);
  @$pb.TagNumber(3)
  void clearRating() => clearField(3);
}

class JoinResponse extends $pb.GeneratedMessage {
  factory JoinResponse({
    $core.bool? success,
    $core.String? message,
    $core.String? queuePosition,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (message != null) {
      $result.message = message;
    }
    if (queuePosition != null) {
      $result.queuePosition = queuePosition;
    }
    return $result;
  }
  JoinResponse._() : super();
  factory JoinResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory JoinResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'JoinResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'queuePosition')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  JoinResponse clone() => JoinResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  JoinResponse copyWith(void Function(JoinResponse) updates) => super.copyWith((message) => updates(message as JoinResponse)) as JoinResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinResponse create() => JoinResponse._();
  JoinResponse createEmptyInstance() => create();
  static $pb.PbList<JoinResponse> createRepeated() => $pb.PbList<JoinResponse>();
  @$core.pragma('dart2js:noInline')
  static JoinResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<JoinResponse>(create);
  static JoinResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get queuePosition => $_getSZ(2);
  @$pb.TagNumber(3)
  set queuePosition($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasQueuePosition() => $_has(2);
  @$pb.TagNumber(3)
  void clearQueuePosition() => clearField(3);
}

/// LeaveMatchmaking
class LeaveRequest extends $pb.GeneratedMessage {
  factory LeaveRequest({
    $core.String? userId,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    return $result;
  }
  LeaveRequest._() : super();
  factory LeaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LeaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LeaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LeaveRequest clone() => LeaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LeaveRequest copyWith(void Function(LeaveRequest) updates) => super.copyWith((message) => updates(message as LeaveRequest)) as LeaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LeaveRequest create() => LeaveRequest._();
  LeaveRequest createEmptyInstance() => create();
  static $pb.PbList<LeaveRequest> createRepeated() => $pb.PbList<LeaveRequest>();
  @$core.pragma('dart2js:noInline')
  static LeaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LeaveRequest>(create);
  static LeaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);
}

class LeaveResponse extends $pb.GeneratedMessage {
  factory LeaveResponse({
    $core.bool? success,
    $core.String? message,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  LeaveResponse._() : super();
  factory LeaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LeaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LeaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LeaveResponse clone() => LeaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LeaveResponse copyWith(void Function(LeaveResponse) updates) => super.copyWith((message) => updates(message as LeaveResponse)) as LeaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LeaveResponse create() => LeaveResponse._();
  LeaveResponse createEmptyInstance() => create();
  static $pb.PbList<LeaveResponse> createRepeated() => $pb.PbList<LeaveResponse>();
  @$core.pragma('dart2js:noInline')
  static LeaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LeaveResponse>(create);
  static LeaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);
}

/// SubscribeToMatch — streamed events back to Flutter
class SubscribeRequest extends $pb.GeneratedMessage {
  factory SubscribeRequest({
    $core.String? userId,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    return $result;
  }
  SubscribeRequest._() : super();
  factory SubscribeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubscribeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubscribeRequest clone() => SubscribeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubscribeRequest copyWith(void Function(SubscribeRequest) updates) => super.copyWith((message) => updates(message as SubscribeRequest)) as SubscribeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeRequest create() => SubscribeRequest._();
  SubscribeRequest createEmptyInstance() => create();
  static $pb.PbList<SubscribeRequest> createRepeated() => $pb.PbList<SubscribeRequest>();
  @$core.pragma('dart2js:noInline')
  static SubscribeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeRequest>(create);
  static SubscribeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);
}

enum MatchEvent_Event {
  matchFound, 
  matchCancelled, 
  waitingUpdate, 
  notSet
}

class MatchEvent extends $pb.GeneratedMessage {
  factory MatchEvent({
    MatchFound? matchFound,
    MatchCancelled? matchCancelled,
    WaitingUpdate? waitingUpdate,
  }) {
    final $result = create();
    if (matchFound != null) {
      $result.matchFound = matchFound;
    }
    if (matchCancelled != null) {
      $result.matchCancelled = matchCancelled;
    }
    if (waitingUpdate != null) {
      $result.waitingUpdate = waitingUpdate;
    }
    return $result;
  }
  MatchEvent._() : super();
  factory MatchEvent.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MatchEvent.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, MatchEvent_Event> _MatchEvent_EventByTag = {
    1 : MatchEvent_Event.matchFound,
    2 : MatchEvent_Event.matchCancelled,
    3 : MatchEvent_Event.waitingUpdate,
    0 : MatchEvent_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MatchEvent', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..aOM<MatchFound>(1, _omitFieldNames ? '' : 'matchFound', subBuilder: MatchFound.create)
    ..aOM<MatchCancelled>(2, _omitFieldNames ? '' : 'matchCancelled', subBuilder: MatchCancelled.create)
    ..aOM<WaitingUpdate>(3, _omitFieldNames ? '' : 'waitingUpdate', subBuilder: WaitingUpdate.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MatchEvent clone() => MatchEvent()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MatchEvent copyWith(void Function(MatchEvent) updates) => super.copyWith((message) => updates(message as MatchEvent)) as MatchEvent;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatchEvent create() => MatchEvent._();
  MatchEvent createEmptyInstance() => create();
  static $pb.PbList<MatchEvent> createRepeated() => $pb.PbList<MatchEvent>();
  @$core.pragma('dart2js:noInline')
  static MatchEvent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MatchEvent>(create);
  static MatchEvent? _defaultInstance;

  MatchEvent_Event whichEvent() => _MatchEvent_EventByTag[$_whichOneof(0)]!;
  void clearEvent() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  MatchFound get matchFound => $_getN(0);
  @$pb.TagNumber(1)
  set matchFound(MatchFound v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasMatchFound() => $_has(0);
  @$pb.TagNumber(1)
  void clearMatchFound() => clearField(1);
  @$pb.TagNumber(1)
  MatchFound ensureMatchFound() => $_ensure(0);

  @$pb.TagNumber(2)
  MatchCancelled get matchCancelled => $_getN(1);
  @$pb.TagNumber(2)
  set matchCancelled(MatchCancelled v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasMatchCancelled() => $_has(1);
  @$pb.TagNumber(2)
  void clearMatchCancelled() => clearField(2);
  @$pb.TagNumber(2)
  MatchCancelled ensureMatchCancelled() => $_ensure(1);

  @$pb.TagNumber(3)
  WaitingUpdate get waitingUpdate => $_getN(2);
  @$pb.TagNumber(3)
  set waitingUpdate(WaitingUpdate v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasWaitingUpdate() => $_has(2);
  @$pb.TagNumber(3)
  void clearWaitingUpdate() => clearField(3);
  @$pb.TagNumber(3)
  WaitingUpdate ensureWaitingUpdate() => $_ensure(2);
}

class MatchFound extends $pb.GeneratedMessage {
  factory MatchFound({
    $core.String? roomId,
    $core.Iterable<Player>? players,
    $core.int? totalRounds,
  }) {
    final $result = create();
    if (roomId != null) {
      $result.roomId = roomId;
    }
    if (players != null) {
      $result.players.addAll(players);
    }
    if (totalRounds != null) {
      $result.totalRounds = totalRounds;
    }
    return $result;
  }
  MatchFound._() : super();
  factory MatchFound.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MatchFound.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MatchFound', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'roomId')
    ..pc<Player>(2, _omitFieldNames ? '' : 'players', $pb.PbFieldType.PM, subBuilder: Player.create)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'totalRounds', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MatchFound clone() => MatchFound()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MatchFound copyWith(void Function(MatchFound) updates) => super.copyWith((message) => updates(message as MatchFound)) as MatchFound;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatchFound create() => MatchFound._();
  MatchFound createEmptyInstance() => create();
  static $pb.PbList<MatchFound> createRepeated() => $pb.PbList<MatchFound>();
  @$core.pragma('dart2js:noInline')
  static MatchFound getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MatchFound>(create);
  static MatchFound? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get roomId => $_getSZ(0);
  @$pb.TagNumber(1)
  set roomId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<Player> get players => $_getList(1);

  @$pb.TagNumber(3)
  $core.int get totalRounds => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalRounds($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTotalRounds() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalRounds() => clearField(3);
}

class MatchCancelled extends $pb.GeneratedMessage {
  factory MatchCancelled({
    $core.String? reason,
  }) {
    final $result = create();
    if (reason != null) {
      $result.reason = reason;
    }
    return $result;
  }
  MatchCancelled._() : super();
  factory MatchCancelled.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MatchCancelled.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MatchCancelled', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MatchCancelled clone() => MatchCancelled()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MatchCancelled copyWith(void Function(MatchCancelled) updates) => super.copyWith((message) => updates(message as MatchCancelled)) as MatchCancelled;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatchCancelled create() => MatchCancelled._();
  MatchCancelled createEmptyInstance() => create();
  static $pb.PbList<MatchCancelled> createRepeated() => $pb.PbList<MatchCancelled>();
  @$core.pragma('dart2js:noInline')
  static MatchCancelled getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MatchCancelled>(create);
  static MatchCancelled? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get reason => $_getSZ(0);
  @$pb.TagNumber(1)
  set reason($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasReason() => $_has(0);
  @$pb.TagNumber(1)
  void clearReason() => clearField(1);
}

class WaitingUpdate extends $pb.GeneratedMessage {
  factory WaitingUpdate({
    $core.int? playersInPool,
    $core.int? estimatedWaitSeconds,
  }) {
    final $result = create();
    if (playersInPool != null) {
      $result.playersInPool = playersInPool;
    }
    if (estimatedWaitSeconds != null) {
      $result.estimatedWaitSeconds = estimatedWaitSeconds;
    }
    return $result;
  }
  WaitingUpdate._() : super();
  factory WaitingUpdate.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WaitingUpdate.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WaitingUpdate', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'playersInPool', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'estimatedWaitSeconds', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WaitingUpdate clone() => WaitingUpdate()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WaitingUpdate copyWith(void Function(WaitingUpdate) updates) => super.copyWith((message) => updates(message as WaitingUpdate)) as WaitingUpdate;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WaitingUpdate create() => WaitingUpdate._();
  WaitingUpdate createEmptyInstance() => create();
  static $pb.PbList<WaitingUpdate> createRepeated() => $pb.PbList<WaitingUpdate>();
  @$core.pragma('dart2js:noInline')
  static WaitingUpdate getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WaitingUpdate>(create);
  static WaitingUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get playersInPool => $_getIZ(0);
  @$pb.TagNumber(1)
  set playersInPool($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPlayersInPool() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlayersInPool() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get estimatedWaitSeconds => $_getIZ(1);
  @$pb.TagNumber(2)
  set estimatedWaitSeconds($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEstimatedWaitSeconds() => $_has(1);
  @$pb.TagNumber(2)
  void clearEstimatedWaitSeconds() => clearField(2);
}

/// GetRoomQuestions
class RoomRequest extends $pb.GeneratedMessage {
  factory RoomRequest({
    $core.String? roomId,
    $core.String? userId,
  }) {
    final $result = create();
    if (roomId != null) {
      $result.roomId = roomId;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    return $result;
  }
  RoomRequest._() : super();
  factory RoomRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RoomRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RoomRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'roomId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RoomRequest clone() => RoomRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RoomRequest copyWith(void Function(RoomRequest) updates) => super.copyWith((message) => updates(message as RoomRequest)) as RoomRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RoomRequest create() => RoomRequest._();
  RoomRequest createEmptyInstance() => create();
  static $pb.PbList<RoomRequest> createRepeated() => $pb.PbList<RoomRequest>();
  @$core.pragma('dart2js:noInline')
  static RoomRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RoomRequest>(create);
  static RoomRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get roomId => $_getSZ(0);
  @$pb.TagNumber(1)
  set roomId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => clearField(2);
}

class QuestionsResponse extends $pb.GeneratedMessage {
  factory QuestionsResponse({
    $core.String? roomId,
    $core.Iterable<Question>? questions,
    $core.int? totalRounds,
  }) {
    final $result = create();
    if (roomId != null) {
      $result.roomId = roomId;
    }
    if (questions != null) {
      $result.questions.addAll(questions);
    }
    if (totalRounds != null) {
      $result.totalRounds = totalRounds;
    }
    return $result;
  }
  QuestionsResponse._() : super();
  factory QuestionsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QuestionsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'QuestionsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'roomId')
    ..pc<Question>(2, _omitFieldNames ? '' : 'questions', $pb.PbFieldType.PM, subBuilder: Question.create)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'totalRounds', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QuestionsResponse clone() => QuestionsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QuestionsResponse copyWith(void Function(QuestionsResponse) updates) => super.copyWith((message) => updates(message as QuestionsResponse)) as QuestionsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QuestionsResponse create() => QuestionsResponse._();
  QuestionsResponse createEmptyInstance() => create();
  static $pb.PbList<QuestionsResponse> createRepeated() => $pb.PbList<QuestionsResponse>();
  @$core.pragma('dart2js:noInline')
  static QuestionsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QuestionsResponse>(create);
  static QuestionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get roomId => $_getSZ(0);
  @$pb.TagNumber(1)
  set roomId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<Question> get questions => $_getList(1);

  @$pb.TagNumber(3)
  $core.int get totalRounds => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalRounds($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTotalRounds() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalRounds() => clearField(3);
}

/// SubmitAnswer
class AnswerRequest extends $pb.GeneratedMessage {
  factory AnswerRequest({
    $core.String? roomId,
    $core.String? userId,
    $core.int? roundNumber,
    $core.String? questionId,
    $core.int? answerIndex,
    $fixnum.Int64? submittedAtMs,
  }) {
    final $result = create();
    if (roomId != null) {
      $result.roomId = roomId;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    if (roundNumber != null) {
      $result.roundNumber = roundNumber;
    }
    if (questionId != null) {
      $result.questionId = questionId;
    }
    if (answerIndex != null) {
      $result.answerIndex = answerIndex;
    }
    if (submittedAtMs != null) {
      $result.submittedAtMs = submittedAtMs;
    }
    return $result;
  }
  AnswerRequest._() : super();
  factory AnswerRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AnswerRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AnswerRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'roomId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'roundNumber', $pb.PbFieldType.O3)
    ..aOS(4, _omitFieldNames ? '' : 'questionId')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'answerIndex', $pb.PbFieldType.O3)
    ..aInt64(6, _omitFieldNames ? '' : 'submittedAtMs')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AnswerRequest clone() => AnswerRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AnswerRequest copyWith(void Function(AnswerRequest) updates) => super.copyWith((message) => updates(message as AnswerRequest)) as AnswerRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnswerRequest create() => AnswerRequest._();
  AnswerRequest createEmptyInstance() => create();
  static $pb.PbList<AnswerRequest> createRepeated() => $pb.PbList<AnswerRequest>();
  @$core.pragma('dart2js:noInline')
  static AnswerRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AnswerRequest>(create);
  static AnswerRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get roomId => $_getSZ(0);
  @$pb.TagNumber(1)
  set roomId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get roundNumber => $_getIZ(2);
  @$pb.TagNumber(3)
  set roundNumber($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRoundNumber() => $_has(2);
  @$pb.TagNumber(3)
  void clearRoundNumber() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get questionId => $_getSZ(3);
  @$pb.TagNumber(4)
  set questionId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasQuestionId() => $_has(3);
  @$pb.TagNumber(4)
  void clearQuestionId() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get answerIndex => $_getIZ(4);
  @$pb.TagNumber(5)
  set answerIndex($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasAnswerIndex() => $_has(4);
  @$pb.TagNumber(5)
  void clearAnswerIndex() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get submittedAtMs => $_getI64(5);
  @$pb.TagNumber(6)
  set submittedAtMs($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasSubmittedAtMs() => $_has(5);
  @$pb.TagNumber(6)
  void clearSubmittedAtMs() => clearField(6);
}

class AnswerAck extends $pb.GeneratedMessage {
  factory AnswerAck({
    $core.bool? received,
    $core.String? message,
  }) {
    final $result = create();
    if (received != null) {
      $result.received = received;
    }
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  AnswerAck._() : super();
  factory AnswerAck.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AnswerAck.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AnswerAck', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'received')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AnswerAck clone() => AnswerAck()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AnswerAck copyWith(void Function(AnswerAck) updates) => super.copyWith((message) => updates(message as AnswerAck)) as AnswerAck;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnswerAck create() => AnswerAck._();
  AnswerAck createEmptyInstance() => create();
  static $pb.PbList<AnswerAck> createRepeated() => $pb.PbList<AnswerAck>();
  @$core.pragma('dart2js:noInline')
  static AnswerAck getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AnswerAck>(create);
  static AnswerAck? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get received => $_getBF(0);
  @$pb.TagNumber(1)
  set received($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasReceived() => $_has(0);
  @$pb.TagNumber(1)
  void clearReceived() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);
}

/// StreamGameEvents
class StreamRequest extends $pb.GeneratedMessage {
  factory StreamRequest({
    $core.String? roomId,
    $core.String? userId,
  }) {
    final $result = create();
    if (roomId != null) {
      $result.roomId = roomId;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    return $result;
  }
  StreamRequest._() : super();
  factory StreamRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StreamRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StreamRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'roomId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StreamRequest clone() => StreamRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StreamRequest copyWith(void Function(StreamRequest) updates) => super.copyWith((message) => updates(message as StreamRequest)) as StreamRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamRequest create() => StreamRequest._();
  StreamRequest createEmptyInstance() => create();
  static $pb.PbList<StreamRequest> createRepeated() => $pb.PbList<StreamRequest>();
  @$core.pragma('dart2js:noInline')
  static StreamRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StreamRequest>(create);
  static StreamRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get roomId => $_getSZ(0);
  @$pb.TagNumber(1)
  set roomId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => clearField(2);
}

enum GameEvent_Event {
  question, 
  leaderboard, 
  roundResult, 
  matchEnd, 
  playerJoined, 
  timerSync, 
  notSet
}

/// GameEvent — the core real-time envelope sent to every Flutter client
class GameEvent extends $pb.GeneratedMessage {
  factory GameEvent({
    QuestionBroadcast? question,
    LeaderboardUpdate? leaderboard,
    RoundResult? roundResult,
    MatchEnd? matchEnd,
    PlayerJoined? playerJoined,
    TimerSync? timerSync,
  }) {
    final $result = create();
    if (question != null) {
      $result.question = question;
    }
    if (leaderboard != null) {
      $result.leaderboard = leaderboard;
    }
    if (roundResult != null) {
      $result.roundResult = roundResult;
    }
    if (matchEnd != null) {
      $result.matchEnd = matchEnd;
    }
    if (playerJoined != null) {
      $result.playerJoined = playerJoined;
    }
    if (timerSync != null) {
      $result.timerSync = timerSync;
    }
    return $result;
  }
  GameEvent._() : super();
  factory GameEvent.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GameEvent.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, GameEvent_Event> _GameEvent_EventByTag = {
    1 : GameEvent_Event.question,
    2 : GameEvent_Event.leaderboard,
    3 : GameEvent_Event.roundResult,
    4 : GameEvent_Event.matchEnd,
    5 : GameEvent_Event.playerJoined,
    6 : GameEvent_Event.timerSync,
    0 : GameEvent_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GameEvent', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5, 6])
    ..aOM<QuestionBroadcast>(1, _omitFieldNames ? '' : 'question', subBuilder: QuestionBroadcast.create)
    ..aOM<LeaderboardUpdate>(2, _omitFieldNames ? '' : 'leaderboard', subBuilder: LeaderboardUpdate.create)
    ..aOM<RoundResult>(3, _omitFieldNames ? '' : 'roundResult', subBuilder: RoundResult.create)
    ..aOM<MatchEnd>(4, _omitFieldNames ? '' : 'matchEnd', subBuilder: MatchEnd.create)
    ..aOM<PlayerJoined>(5, _omitFieldNames ? '' : 'playerJoined', subBuilder: PlayerJoined.create)
    ..aOM<TimerSync>(6, _omitFieldNames ? '' : 'timerSync', subBuilder: TimerSync.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GameEvent clone() => GameEvent()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GameEvent copyWith(void Function(GameEvent) updates) => super.copyWith((message) => updates(message as GameEvent)) as GameEvent;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GameEvent create() => GameEvent._();
  GameEvent createEmptyInstance() => create();
  static $pb.PbList<GameEvent> createRepeated() => $pb.PbList<GameEvent>();
  @$core.pragma('dart2js:noInline')
  static GameEvent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GameEvent>(create);
  static GameEvent? _defaultInstance;

  GameEvent_Event whichEvent() => _GameEvent_EventByTag[$_whichOneof(0)]!;
  void clearEvent() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  QuestionBroadcast get question => $_getN(0);
  @$pb.TagNumber(1)
  set question(QuestionBroadcast v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuestion() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuestion() => clearField(1);
  @$pb.TagNumber(1)
  QuestionBroadcast ensureQuestion() => $_ensure(0);

  @$pb.TagNumber(2)
  LeaderboardUpdate get leaderboard => $_getN(1);
  @$pb.TagNumber(2)
  set leaderboard(LeaderboardUpdate v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasLeaderboard() => $_has(1);
  @$pb.TagNumber(2)
  void clearLeaderboard() => clearField(2);
  @$pb.TagNumber(2)
  LeaderboardUpdate ensureLeaderboard() => $_ensure(1);

  @$pb.TagNumber(3)
  RoundResult get roundResult => $_getN(2);
  @$pb.TagNumber(3)
  set roundResult(RoundResult v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasRoundResult() => $_has(2);
  @$pb.TagNumber(3)
  void clearRoundResult() => clearField(3);
  @$pb.TagNumber(3)
  RoundResult ensureRoundResult() => $_ensure(2);

  @$pb.TagNumber(4)
  MatchEnd get matchEnd => $_getN(3);
  @$pb.TagNumber(4)
  set matchEnd(MatchEnd v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasMatchEnd() => $_has(3);
  @$pb.TagNumber(4)
  void clearMatchEnd() => clearField(4);
  @$pb.TagNumber(4)
  MatchEnd ensureMatchEnd() => $_ensure(3);

  @$pb.TagNumber(5)
  PlayerJoined get playerJoined => $_getN(4);
  @$pb.TagNumber(5)
  set playerJoined(PlayerJoined v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasPlayerJoined() => $_has(4);
  @$pb.TagNumber(5)
  void clearPlayerJoined() => clearField(5);
  @$pb.TagNumber(5)
  PlayerJoined ensurePlayerJoined() => $_ensure(4);

  @$pb.TagNumber(6)
  TimerSync get timerSync => $_getN(5);
  @$pb.TagNumber(6)
  set timerSync(TimerSync v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasTimerSync() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimerSync() => clearField(6);
  @$pb.TagNumber(6)
  TimerSync ensureTimerSync() => $_ensure(5);
}

/// Sent at the start of each round — shows the question + starts countdown
class QuestionBroadcast extends $pb.GeneratedMessage {
  factory QuestionBroadcast({
    $core.int? roundNumber,
    Question? question,
    $fixnum.Int64? deadlineMs,
  }) {
    final $result = create();
    if (roundNumber != null) {
      $result.roundNumber = roundNumber;
    }
    if (question != null) {
      $result.question = question;
    }
    if (deadlineMs != null) {
      $result.deadlineMs = deadlineMs;
    }
    return $result;
  }
  QuestionBroadcast._() : super();
  factory QuestionBroadcast.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QuestionBroadcast.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'QuestionBroadcast', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'roundNumber', $pb.PbFieldType.O3)
    ..aOM<Question>(2, _omitFieldNames ? '' : 'question', subBuilder: Question.create)
    ..aInt64(3, _omitFieldNames ? '' : 'deadlineMs')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QuestionBroadcast clone() => QuestionBroadcast()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QuestionBroadcast copyWith(void Function(QuestionBroadcast) updates) => super.copyWith((message) => updates(message as QuestionBroadcast)) as QuestionBroadcast;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QuestionBroadcast create() => QuestionBroadcast._();
  QuestionBroadcast createEmptyInstance() => create();
  static $pb.PbList<QuestionBroadcast> createRepeated() => $pb.PbList<QuestionBroadcast>();
  @$core.pragma('dart2js:noInline')
  static QuestionBroadcast getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QuestionBroadcast>(create);
  static QuestionBroadcast? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get roundNumber => $_getIZ(0);
  @$pb.TagNumber(1)
  set roundNumber($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRoundNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoundNumber() => clearField(1);

  @$pb.TagNumber(2)
  Question get question => $_getN(1);
  @$pb.TagNumber(2)
  set question(Question v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasQuestion() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuestion() => clearField(2);
  @$pb.TagNumber(2)
  Question ensureQuestion() => $_ensure(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get deadlineMs => $_getI64(2);
  @$pb.TagNumber(3)
  set deadlineMs($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDeadlineMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeadlineMs() => clearField(3);
}

/// Sent after every score update — refreshes the leaderboard overlay
class LeaderboardUpdate extends $pb.GeneratedMessage {
  factory LeaderboardUpdate({
    $core.String? roomId,
    $core.int? roundNumber,
    $core.Iterable<PlayerScore>? scores,
  }) {
    final $result = create();
    if (roomId != null) {
      $result.roomId = roomId;
    }
    if (roundNumber != null) {
      $result.roundNumber = roundNumber;
    }
    if (scores != null) {
      $result.scores.addAll(scores);
    }
    return $result;
  }
  LeaderboardUpdate._() : super();
  factory LeaderboardUpdate.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LeaderboardUpdate.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LeaderboardUpdate', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'roomId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'roundNumber', $pb.PbFieldType.O3)
    ..pc<PlayerScore>(3, _omitFieldNames ? '' : 'scores', $pb.PbFieldType.PM, subBuilder: PlayerScore.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LeaderboardUpdate clone() => LeaderboardUpdate()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LeaderboardUpdate copyWith(void Function(LeaderboardUpdate) updates) => super.copyWith((message) => updates(message as LeaderboardUpdate)) as LeaderboardUpdate;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LeaderboardUpdate create() => LeaderboardUpdate._();
  LeaderboardUpdate createEmptyInstance() => create();
  static $pb.PbList<LeaderboardUpdate> createRepeated() => $pb.PbList<LeaderboardUpdate>();
  @$core.pragma('dart2js:noInline')
  static LeaderboardUpdate getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LeaderboardUpdate>(create);
  static LeaderboardUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get roomId => $_getSZ(0);
  @$pb.TagNumber(1)
  set roomId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get roundNumber => $_getIZ(1);
  @$pb.TagNumber(2)
  set roundNumber($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRoundNumber() => $_has(1);
  @$pb.TagNumber(2)
  void clearRoundNumber() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<PlayerScore> get scores => $_getList(2);
}

/// Sent after all answers are in (or timer expires) for a round
class RoundResult extends $pb.GeneratedMessage {
  factory RoundResult({
    $core.int? roundNumber,
    $core.String? questionId,
    $core.int? correctIndex,
    $core.Iterable<PlayerScore>? scores,
    $core.String? fastestUserId,
  }) {
    final $result = create();
    if (roundNumber != null) {
      $result.roundNumber = roundNumber;
    }
    if (questionId != null) {
      $result.questionId = questionId;
    }
    if (correctIndex != null) {
      $result.correctIndex = correctIndex;
    }
    if (scores != null) {
      $result.scores.addAll(scores);
    }
    if (fastestUserId != null) {
      $result.fastestUserId = fastestUserId;
    }
    return $result;
  }
  RoundResult._() : super();
  factory RoundResult.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RoundResult.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RoundResult', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'roundNumber', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'questionId')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'correctIndex', $pb.PbFieldType.O3)
    ..pc<PlayerScore>(4, _omitFieldNames ? '' : 'scores', $pb.PbFieldType.PM, subBuilder: PlayerScore.create)
    ..aOS(5, _omitFieldNames ? '' : 'fastestUserId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RoundResult clone() => RoundResult()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RoundResult copyWith(void Function(RoundResult) updates) => super.copyWith((message) => updates(message as RoundResult)) as RoundResult;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RoundResult create() => RoundResult._();
  RoundResult createEmptyInstance() => create();
  static $pb.PbList<RoundResult> createRepeated() => $pb.PbList<RoundResult>();
  @$core.pragma('dart2js:noInline')
  static RoundResult getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RoundResult>(create);
  static RoundResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get roundNumber => $_getIZ(0);
  @$pb.TagNumber(1)
  set roundNumber($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRoundNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoundNumber() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get questionId => $_getSZ(1);
  @$pb.TagNumber(2)
  set questionId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasQuestionId() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuestionId() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get correctIndex => $_getIZ(2);
  @$pb.TagNumber(3)
  set correctIndex($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCorrectIndex() => $_has(2);
  @$pb.TagNumber(3)
  void clearCorrectIndex() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<PlayerScore> get scores => $_getList(3);

  @$pb.TagNumber(5)
  $core.String get fastestUserId => $_getSZ(4);
  @$pb.TagNumber(5)
  set fastestUserId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFastestUserId() => $_has(4);
  @$pb.TagNumber(5)
  void clearFastestUserId() => clearField(5);
}

/// Sent once at the very end of the match
class MatchEnd extends $pb.GeneratedMessage {
  factory MatchEnd({
    $core.String? roomId,
    $core.String? winnerUserId,
    $core.String? winnerUsername,
    $core.Iterable<PlayerScore>? finalScores,
    $core.int? totalRounds,
    $core.int? durationSeconds,
  }) {
    final $result = create();
    if (roomId != null) {
      $result.roomId = roomId;
    }
    if (winnerUserId != null) {
      $result.winnerUserId = winnerUserId;
    }
    if (winnerUsername != null) {
      $result.winnerUsername = winnerUsername;
    }
    if (finalScores != null) {
      $result.finalScores.addAll(finalScores);
    }
    if (totalRounds != null) {
      $result.totalRounds = totalRounds;
    }
    if (durationSeconds != null) {
      $result.durationSeconds = durationSeconds;
    }
    return $result;
  }
  MatchEnd._() : super();
  factory MatchEnd.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MatchEnd.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MatchEnd', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'roomId')
    ..aOS(2, _omitFieldNames ? '' : 'winnerUserId')
    ..aOS(3, _omitFieldNames ? '' : 'winnerUsername')
    ..pc<PlayerScore>(4, _omitFieldNames ? '' : 'finalScores', $pb.PbFieldType.PM, subBuilder: PlayerScore.create)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'totalRounds', $pb.PbFieldType.O3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'durationSeconds', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MatchEnd clone() => MatchEnd()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MatchEnd copyWith(void Function(MatchEnd) updates) => super.copyWith((message) => updates(message as MatchEnd)) as MatchEnd;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatchEnd create() => MatchEnd._();
  MatchEnd createEmptyInstance() => create();
  static $pb.PbList<MatchEnd> createRepeated() => $pb.PbList<MatchEnd>();
  @$core.pragma('dart2js:noInline')
  static MatchEnd getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MatchEnd>(create);
  static MatchEnd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get roomId => $_getSZ(0);
  @$pb.TagNumber(1)
  set roomId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get winnerUserId => $_getSZ(1);
  @$pb.TagNumber(2)
  set winnerUserId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWinnerUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWinnerUserId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get winnerUsername => $_getSZ(2);
  @$pb.TagNumber(3)
  set winnerUsername($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWinnerUsername() => $_has(2);
  @$pb.TagNumber(3)
  void clearWinnerUsername() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<PlayerScore> get finalScores => $_getList(3);

  @$pb.TagNumber(5)
  $core.int get totalRounds => $_getIZ(4);
  @$pb.TagNumber(5)
  set totalRounds($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTotalRounds() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalRounds() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get durationSeconds => $_getIZ(5);
  @$pb.TagNumber(6)
  set durationSeconds($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasDurationSeconds() => $_has(5);
  @$pb.TagNumber(6)
  void clearDurationSeconds() => clearField(6);
}

/// Sent when a new player connects or reconnects mid-match
class PlayerJoined extends $pb.GeneratedMessage {
  factory PlayerJoined({
    Player? player,
    $core.int? roundNumber,
    MatchState? state,
  }) {
    final $result = create();
    if (player != null) {
      $result.player = player;
    }
    if (roundNumber != null) {
      $result.roundNumber = roundNumber;
    }
    if (state != null) {
      $result.state = state;
    }
    return $result;
  }
  PlayerJoined._() : super();
  factory PlayerJoined.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PlayerJoined.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PlayerJoined', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..aOM<Player>(1, _omitFieldNames ? '' : 'player', subBuilder: Player.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'roundNumber', $pb.PbFieldType.O3)
    ..e<MatchState>(3, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: MatchState.MATCH_STATE_UNSPECIFIED, valueOf: MatchState.valueOf, enumValues: MatchState.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PlayerJoined clone() => PlayerJoined()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PlayerJoined copyWith(void Function(PlayerJoined) updates) => super.copyWith((message) => updates(message as PlayerJoined)) as PlayerJoined;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PlayerJoined create() => PlayerJoined._();
  PlayerJoined createEmptyInstance() => create();
  static $pb.PbList<PlayerJoined> createRepeated() => $pb.PbList<PlayerJoined>();
  @$core.pragma('dart2js:noInline')
  static PlayerJoined getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PlayerJoined>(create);
  static PlayerJoined? _defaultInstance;

  @$pb.TagNumber(1)
  Player get player => $_getN(0);
  @$pb.TagNumber(1)
  set player(Player v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasPlayer() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlayer() => clearField(1);
  @$pb.TagNumber(1)
  Player ensurePlayer() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get roundNumber => $_getIZ(1);
  @$pb.TagNumber(2)
  set roundNumber($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRoundNumber() => $_has(1);
  @$pb.TagNumber(2)
  void clearRoundNumber() => clearField(2);

  @$pb.TagNumber(3)
  MatchState get state => $_getN(2);
  @$pb.TagNumber(3)
  set state(MatchState v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasState() => $_has(2);
  @$pb.TagNumber(3)
  void clearState() => clearField(3);
}

/// Sent periodically to keep client clocks in sync with server
class TimerSync extends $pb.GeneratedMessage {
  factory TimerSync({
    $core.int? roundNumber,
    $fixnum.Int64? serverTimeMs,
    $fixnum.Int64? deadlineMs,
  }) {
    final $result = create();
    if (roundNumber != null) {
      $result.roundNumber = roundNumber;
    }
    if (serverTimeMs != null) {
      $result.serverTimeMs = serverTimeMs;
    }
    if (deadlineMs != null) {
      $result.deadlineMs = deadlineMs;
    }
    return $result;
  }
  TimerSync._() : super();
  factory TimerSync.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TimerSync.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TimerSync', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'roundNumber', $pb.PbFieldType.O3)
    ..aInt64(2, _omitFieldNames ? '' : 'serverTimeMs')
    ..aInt64(3, _omitFieldNames ? '' : 'deadlineMs')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TimerSync clone() => TimerSync()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TimerSync copyWith(void Function(TimerSync) updates) => super.copyWith((message) => updates(message as TimerSync)) as TimerSync;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TimerSync create() => TimerSync._();
  TimerSync createEmptyInstance() => create();
  static $pb.PbList<TimerSync> createRepeated() => $pb.PbList<TimerSync>();
  @$core.pragma('dart2js:noInline')
  static TimerSync getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TimerSync>(create);
  static TimerSync? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get roundNumber => $_getIZ(0);
  @$pb.TagNumber(1)
  set roundNumber($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRoundNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoundNumber() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get serverTimeMs => $_getI64(1);
  @$pb.TagNumber(2)
  set serverTimeMs($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasServerTimeMs() => $_has(1);
  @$pb.TagNumber(2)
  void clearServerTimeMs() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get deadlineMs => $_getI64(2);
  @$pb.TagNumber(3)
  set deadlineMs($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDeadlineMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeadlineMs() => clearField(3);
}

/// CalculateScore
class ScoreRequest extends $pb.GeneratedMessage {
  factory ScoreRequest({
    $core.String? roomId,
    $core.String? userId,
    $core.int? roundNumber,
    $core.String? questionId,
    $core.int? answerIndex,
    $fixnum.Int64? submittedAtMs,
    $fixnum.Int64? roundStartedAtMs,
  }) {
    final $result = create();
    if (roomId != null) {
      $result.roomId = roomId;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    if (roundNumber != null) {
      $result.roundNumber = roundNumber;
    }
    if (questionId != null) {
      $result.questionId = questionId;
    }
    if (answerIndex != null) {
      $result.answerIndex = answerIndex;
    }
    if (submittedAtMs != null) {
      $result.submittedAtMs = submittedAtMs;
    }
    if (roundStartedAtMs != null) {
      $result.roundStartedAtMs = roundStartedAtMs;
    }
    return $result;
  }
  ScoreRequest._() : super();
  factory ScoreRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ScoreRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ScoreRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'roomId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'roundNumber', $pb.PbFieldType.O3)
    ..aOS(4, _omitFieldNames ? '' : 'questionId')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'answerIndex', $pb.PbFieldType.O3)
    ..aInt64(6, _omitFieldNames ? '' : 'submittedAtMs')
    ..aInt64(7, _omitFieldNames ? '' : 'roundStartedAtMs')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ScoreRequest clone() => ScoreRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ScoreRequest copyWith(void Function(ScoreRequest) updates) => super.copyWith((message) => updates(message as ScoreRequest)) as ScoreRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScoreRequest create() => ScoreRequest._();
  ScoreRequest createEmptyInstance() => create();
  static $pb.PbList<ScoreRequest> createRepeated() => $pb.PbList<ScoreRequest>();
  @$core.pragma('dart2js:noInline')
  static ScoreRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ScoreRequest>(create);
  static ScoreRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get roomId => $_getSZ(0);
  @$pb.TagNumber(1)
  set roomId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get roundNumber => $_getIZ(2);
  @$pb.TagNumber(3)
  set roundNumber($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRoundNumber() => $_has(2);
  @$pb.TagNumber(3)
  void clearRoundNumber() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get questionId => $_getSZ(3);
  @$pb.TagNumber(4)
  set questionId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasQuestionId() => $_has(3);
  @$pb.TagNumber(4)
  void clearQuestionId() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get answerIndex => $_getIZ(4);
  @$pb.TagNumber(5)
  set answerIndex($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasAnswerIndex() => $_has(4);
  @$pb.TagNumber(5)
  void clearAnswerIndex() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get submittedAtMs => $_getI64(5);
  @$pb.TagNumber(6)
  set submittedAtMs($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasSubmittedAtMs() => $_has(5);
  @$pb.TagNumber(6)
  void clearSubmittedAtMs() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get roundStartedAtMs => $_getI64(6);
  @$pb.TagNumber(7)
  set roundStartedAtMs($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasRoundStartedAtMs() => $_has(6);
  @$pb.TagNumber(7)
  void clearRoundStartedAtMs() => clearField(7);
}

class ScoreResponse extends $pb.GeneratedMessage {
  factory ScoreResponse({
    $core.bool? isCorrect,
    $core.int? pointsAwarded,
    $core.int? totalScore,
    $core.int? speedBonus,
    $core.int? newRank,
  }) {
    final $result = create();
    if (isCorrect != null) {
      $result.isCorrect = isCorrect;
    }
    if (pointsAwarded != null) {
      $result.pointsAwarded = pointsAwarded;
    }
    if (totalScore != null) {
      $result.totalScore = totalScore;
    }
    if (speedBonus != null) {
      $result.speedBonus = speedBonus;
    }
    if (newRank != null) {
      $result.newRank = newRank;
    }
    return $result;
  }
  ScoreResponse._() : super();
  factory ScoreResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ScoreResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ScoreResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'isCorrect')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'pointsAwarded', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'totalScore', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'speedBonus', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'newRank', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ScoreResponse clone() => ScoreResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ScoreResponse copyWith(void Function(ScoreResponse) updates) => super.copyWith((message) => updates(message as ScoreResponse)) as ScoreResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScoreResponse create() => ScoreResponse._();
  ScoreResponse createEmptyInstance() => create();
  static $pb.PbList<ScoreResponse> createRepeated() => $pb.PbList<ScoreResponse>();
  @$core.pragma('dart2js:noInline')
  static ScoreResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ScoreResponse>(create);
  static ScoreResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isCorrect => $_getBF(0);
  @$pb.TagNumber(1)
  set isCorrect($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIsCorrect() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsCorrect() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get pointsAwarded => $_getIZ(1);
  @$pb.TagNumber(2)
  set pointsAwarded($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPointsAwarded() => $_has(1);
  @$pb.TagNumber(2)
  void clearPointsAwarded() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalScore => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalScore($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTotalScore() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalScore() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get speedBonus => $_getIZ(3);
  @$pb.TagNumber(4)
  set speedBonus($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSpeedBonus() => $_has(3);
  @$pb.TagNumber(4)
  void clearSpeedBonus() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get newRank => $_getIZ(4);
  @$pb.TagNumber(5)
  set newRank($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasNewRank() => $_has(4);
  @$pb.TagNumber(5)
  void clearNewRank() => clearField(5);
}

/// GetLeaderboard
class LeaderboardRequest extends $pb.GeneratedMessage {
  factory LeaderboardRequest({
    $core.String? roomId,
  }) {
    final $result = create();
    if (roomId != null) {
      $result.roomId = roomId;
    }
    return $result;
  }
  LeaderboardRequest._() : super();
  factory LeaderboardRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LeaderboardRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LeaderboardRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'roomId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LeaderboardRequest clone() => LeaderboardRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LeaderboardRequest copyWith(void Function(LeaderboardRequest) updates) => super.copyWith((message) => updates(message as LeaderboardRequest)) as LeaderboardRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LeaderboardRequest create() => LeaderboardRequest._();
  LeaderboardRequest createEmptyInstance() => create();
  static $pb.PbList<LeaderboardRequest> createRepeated() => $pb.PbList<LeaderboardRequest>();
  @$core.pragma('dart2js:noInline')
  static LeaderboardRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LeaderboardRequest>(create);
  static LeaderboardRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get roomId => $_getSZ(0);
  @$pb.TagNumber(1)
  set roomId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => clearField(1);
}

class LeaderboardResponse extends $pb.GeneratedMessage {
  factory LeaderboardResponse({
    $core.String? roomId,
    $core.int? roundNumber,
    $core.Iterable<PlayerScore>? scores,
  }) {
    final $result = create();
    if (roomId != null) {
      $result.roomId = roomId;
    }
    if (roundNumber != null) {
      $result.roundNumber = roundNumber;
    }
    if (scores != null) {
      $result.scores.addAll(scores);
    }
    return $result;
  }
  LeaderboardResponse._() : super();
  factory LeaderboardResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LeaderboardResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LeaderboardResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'quiz'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'roomId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'roundNumber', $pb.PbFieldType.O3)
    ..pc<PlayerScore>(3, _omitFieldNames ? '' : 'scores', $pb.PbFieldType.PM, subBuilder: PlayerScore.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LeaderboardResponse clone() => LeaderboardResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LeaderboardResponse copyWith(void Function(LeaderboardResponse) updates) => super.copyWith((message) => updates(message as LeaderboardResponse)) as LeaderboardResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LeaderboardResponse create() => LeaderboardResponse._();
  LeaderboardResponse createEmptyInstance() => create();
  static $pb.PbList<LeaderboardResponse> createRepeated() => $pb.PbList<LeaderboardResponse>();
  @$core.pragma('dart2js:noInline')
  static LeaderboardResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LeaderboardResponse>(create);
  static LeaderboardResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get roomId => $_getSZ(0);
  @$pb.TagNumber(1)
  set roomId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get roundNumber => $_getIZ(1);
  @$pb.TagNumber(2)
  set roundNumber($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRoundNumber() => $_has(1);
  @$pb.TagNumber(2)
  void clearRoundNumber() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<PlayerScore> get scores => $_getList(2);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');

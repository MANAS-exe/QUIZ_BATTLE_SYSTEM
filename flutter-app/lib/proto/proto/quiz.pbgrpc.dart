//
//  Generated code. Do not modify.
//  source: proto/quiz.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'quiz.pb.dart' as $0;

export 'quiz.pb.dart';

@$pb.GrpcServiceName('quiz.AuthService')
class AuthServiceClient extends $grpc.Client {
  static final _$register = $grpc.ClientMethod<$0.AuthRequest, $0.AuthResponse>(
      '/quiz.AuthService/Register',
      ($0.AuthRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.AuthResponse.fromBuffer(value));
  static final _$login = $grpc.ClientMethod<$0.AuthRequest, $0.AuthResponse>(
      '/quiz.AuthService/Login',
      ($0.AuthRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.AuthResponse.fromBuffer(value));

  AuthServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.AuthResponse> register($0.AuthRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$register, request, options: options);
  }

  $grpc.ResponseFuture<$0.AuthResponse> login($0.AuthRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$login, request, options: options);
  }
}

@$pb.GrpcServiceName('quiz.AuthService')
abstract class AuthServiceBase extends $grpc.Service {
  $core.String get $name => 'quiz.AuthService';

  AuthServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.AuthRequest, $0.AuthResponse>(
        'Register',
        register_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AuthRequest.fromBuffer(value),
        ($0.AuthResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AuthRequest, $0.AuthResponse>(
        'Login',
        login_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AuthRequest.fromBuffer(value),
        ($0.AuthResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.AuthResponse> register_Pre($grpc.ServiceCall call, $async.Future<$0.AuthRequest> request) async {
    return register(call, await request);
  }

  $async.Future<$0.AuthResponse> login_Pre($grpc.ServiceCall call, $async.Future<$0.AuthRequest> request) async {
    return login(call, await request);
  }

  $async.Future<$0.AuthResponse> register($grpc.ServiceCall call, $0.AuthRequest request);
  $async.Future<$0.AuthResponse> login($grpc.ServiceCall call, $0.AuthRequest request);
}
@$pb.GrpcServiceName('quiz.MatchmakingService')
class MatchmakingServiceClient extends $grpc.Client {
  static final _$joinMatchmaking = $grpc.ClientMethod<$0.JoinRequest, $0.JoinResponse>(
      '/quiz.MatchmakingService/JoinMatchmaking',
      ($0.JoinRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.JoinResponse.fromBuffer(value));
  static final _$leaveMatchmaking = $grpc.ClientMethod<$0.LeaveRequest, $0.LeaveResponse>(
      '/quiz.MatchmakingService/LeaveMatchmaking',
      ($0.LeaveRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.LeaveResponse.fromBuffer(value));
  static final _$subscribeToMatch = $grpc.ClientMethod<$0.SubscribeRequest, $0.MatchEvent>(
      '/quiz.MatchmakingService/SubscribeToMatch',
      ($0.SubscribeRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.MatchEvent.fromBuffer(value));

  MatchmakingServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.JoinResponse> joinMatchmaking($0.JoinRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$joinMatchmaking, request, options: options);
  }

  $grpc.ResponseFuture<$0.LeaveResponse> leaveMatchmaking($0.LeaveRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$leaveMatchmaking, request, options: options);
  }

  $grpc.ResponseStream<$0.MatchEvent> subscribeToMatch($0.SubscribeRequest request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$subscribeToMatch, $async.Stream.fromIterable([request]), options: options);
  }
}

@$pb.GrpcServiceName('quiz.MatchmakingService')
abstract class MatchmakingServiceBase extends $grpc.Service {
  $core.String get $name => 'quiz.MatchmakingService';

  MatchmakingServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.JoinRequest, $0.JoinResponse>(
        'JoinMatchmaking',
        joinMatchmaking_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.JoinRequest.fromBuffer(value),
        ($0.JoinResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LeaveRequest, $0.LeaveResponse>(
        'LeaveMatchmaking',
        leaveMatchmaking_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LeaveRequest.fromBuffer(value),
        ($0.LeaveResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SubscribeRequest, $0.MatchEvent>(
        'SubscribeToMatch',
        subscribeToMatch_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.SubscribeRequest.fromBuffer(value),
        ($0.MatchEvent value) => value.writeToBuffer()));
  }

  $async.Future<$0.JoinResponse> joinMatchmaking_Pre($grpc.ServiceCall call, $async.Future<$0.JoinRequest> request) async {
    return joinMatchmaking(call, await request);
  }

  $async.Future<$0.LeaveResponse> leaveMatchmaking_Pre($grpc.ServiceCall call, $async.Future<$0.LeaveRequest> request) async {
    return leaveMatchmaking(call, await request);
  }

  $async.Stream<$0.MatchEvent> subscribeToMatch_Pre($grpc.ServiceCall call, $async.Future<$0.SubscribeRequest> request) async* {
    yield* subscribeToMatch(call, await request);
  }

  $async.Future<$0.JoinResponse> joinMatchmaking($grpc.ServiceCall call, $0.JoinRequest request);
  $async.Future<$0.LeaveResponse> leaveMatchmaking($grpc.ServiceCall call, $0.LeaveRequest request);
  $async.Stream<$0.MatchEvent> subscribeToMatch($grpc.ServiceCall call, $0.SubscribeRequest request);
}
@$pb.GrpcServiceName('quiz.QuizService')
class QuizServiceClient extends $grpc.Client {
  static final _$getRoomQuestions = $grpc.ClientMethod<$0.RoomRequest, $0.QuestionsResponse>(
      '/quiz.QuizService/GetRoomQuestions',
      ($0.RoomRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.QuestionsResponse.fromBuffer(value));
  static final _$submitAnswer = $grpc.ClientMethod<$0.AnswerRequest, $0.AnswerAck>(
      '/quiz.QuizService/SubmitAnswer',
      ($0.AnswerRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.AnswerAck.fromBuffer(value));
  static final _$streamGameEvents = $grpc.ClientMethod<$0.StreamRequest, $0.GameEvent>(
      '/quiz.QuizService/StreamGameEvents',
      ($0.StreamRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GameEvent.fromBuffer(value));

  QuizServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.QuestionsResponse> getRoomQuestions($0.RoomRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getRoomQuestions, request, options: options);
  }

  $grpc.ResponseFuture<$0.AnswerAck> submitAnswer($0.AnswerRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$submitAnswer, request, options: options);
  }

  $grpc.ResponseStream<$0.GameEvent> streamGameEvents($0.StreamRequest request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$streamGameEvents, $async.Stream.fromIterable([request]), options: options);
  }
}

@$pb.GrpcServiceName('quiz.QuizService')
abstract class QuizServiceBase extends $grpc.Service {
  $core.String get $name => 'quiz.QuizService';

  QuizServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.RoomRequest, $0.QuestionsResponse>(
        'GetRoomQuestions',
        getRoomQuestions_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RoomRequest.fromBuffer(value),
        ($0.QuestionsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AnswerRequest, $0.AnswerAck>(
        'SubmitAnswer',
        submitAnswer_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AnswerRequest.fromBuffer(value),
        ($0.AnswerAck value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StreamRequest, $0.GameEvent>(
        'StreamGameEvents',
        streamGameEvents_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.StreamRequest.fromBuffer(value),
        ($0.GameEvent value) => value.writeToBuffer()));
  }

  $async.Future<$0.QuestionsResponse> getRoomQuestions_Pre($grpc.ServiceCall call, $async.Future<$0.RoomRequest> request) async {
    return getRoomQuestions(call, await request);
  }

  $async.Future<$0.AnswerAck> submitAnswer_Pre($grpc.ServiceCall call, $async.Future<$0.AnswerRequest> request) async {
    return submitAnswer(call, await request);
  }

  $async.Stream<$0.GameEvent> streamGameEvents_Pre($grpc.ServiceCall call, $async.Future<$0.StreamRequest> request) async* {
    yield* streamGameEvents(call, await request);
  }

  $async.Future<$0.QuestionsResponse> getRoomQuestions($grpc.ServiceCall call, $0.RoomRequest request);
  $async.Future<$0.AnswerAck> submitAnswer($grpc.ServiceCall call, $0.AnswerRequest request);
  $async.Stream<$0.GameEvent> streamGameEvents($grpc.ServiceCall call, $0.StreamRequest request);
}
@$pb.GrpcServiceName('quiz.ScoringService')
class ScoringServiceClient extends $grpc.Client {
  static final _$calculateScore = $grpc.ClientMethod<$0.ScoreRequest, $0.ScoreResponse>(
      '/quiz.ScoringService/CalculateScore',
      ($0.ScoreRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ScoreResponse.fromBuffer(value));
  static final _$getLeaderboard = $grpc.ClientMethod<$0.LeaderboardRequest, $0.LeaderboardResponse>(
      '/quiz.ScoringService/GetLeaderboard',
      ($0.LeaderboardRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.LeaderboardResponse.fromBuffer(value));

  ScoringServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.ScoreResponse> calculateScore($0.ScoreRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$calculateScore, request, options: options);
  }

  $grpc.ResponseFuture<$0.LeaderboardResponse> getLeaderboard($0.LeaderboardRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getLeaderboard, request, options: options);
  }
}

@$pb.GrpcServiceName('quiz.ScoringService')
abstract class ScoringServiceBase extends $grpc.Service {
  $core.String get $name => 'quiz.ScoringService';

  ScoringServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ScoreRequest, $0.ScoreResponse>(
        'CalculateScore',
        calculateScore_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ScoreRequest.fromBuffer(value),
        ($0.ScoreResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LeaderboardRequest, $0.LeaderboardResponse>(
        'GetLeaderboard',
        getLeaderboard_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LeaderboardRequest.fromBuffer(value),
        ($0.LeaderboardResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.ScoreResponse> calculateScore_Pre($grpc.ServiceCall call, $async.Future<$0.ScoreRequest> request) async {
    return calculateScore(call, await request);
  }

  $async.Future<$0.LeaderboardResponse> getLeaderboard_Pre($grpc.ServiceCall call, $async.Future<$0.LeaderboardRequest> request) async {
    return getLeaderboard(call, await request);
  }

  $async.Future<$0.ScoreResponse> calculateScore($grpc.ServiceCall call, $0.ScoreRequest request);
  $async.Future<$0.LeaderboardResponse> getLeaderboard($grpc.ServiceCall call, $0.LeaderboardRequest request);
}

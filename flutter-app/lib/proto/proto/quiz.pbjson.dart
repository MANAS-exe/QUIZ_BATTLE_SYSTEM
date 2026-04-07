//
//  Generated code. Do not modify.
//  source: proto/quiz.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use difficultyDescriptor instead')
const Difficulty$json = {
  '1': 'Difficulty',
  '2': [
    {'1': 'DIFFICULTY_UNSPECIFIED', '2': 0},
    {'1': 'EASY', '2': 1},
    {'1': 'MEDIUM', '2': 2},
    {'1': 'HARD', '2': 3},
  ],
};

/// Descriptor for `Difficulty`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List difficultyDescriptor = $convert.base64Decode(
    'CgpEaWZmaWN1bHR5EhoKFkRJRkZJQ1VMVFlfVU5TUEVDSUZJRUQQABIICgRFQVNZEAESCgoGTU'
    'VESVVNEAISCAoESEFSRBAD');

@$core.Deprecated('Use matchStateDescriptor instead')
const MatchState$json = {
  '1': 'MatchState',
  '2': [
    {'1': 'MATCH_STATE_UNSPECIFIED', '2': 0},
    {'1': 'WAITING', '2': 1},
    {'1': 'IN_PROGRESS', '2': 2},
    {'1': 'FINISHED', '2': 3},
  ],
};

/// Descriptor for `MatchState`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List matchStateDescriptor = $convert.base64Decode(
    'CgpNYXRjaFN0YXRlEhsKF01BVENIX1NUQVRFX1VOU1BFQ0lGSUVEEAASCwoHV0FJVElORxABEg'
    '8KC0lOX1BST0dSRVNTEAISDAoIRklOSVNIRUQQAw==');

@$core.Deprecated('Use playerStatusDescriptor instead')
const PlayerStatus$json = {
  '1': 'PlayerStatus',
  '2': [
    {'1': 'PLAYER_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'CONNECTED', '2': 1},
    {'1': 'DISCONNECTED', '2': 2},
    {'1': 'RECONNECTING', '2': 3},
  ],
};

/// Descriptor for `PlayerStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List playerStatusDescriptor = $convert.base64Decode(
    'CgxQbGF5ZXJTdGF0dXMSHQoZUExBWUVSX1NUQVRVU19VTlNQRUNJRklFRBAAEg0KCUNPTk5FQ1'
    'RFRBABEhAKDERJU0NPTk5FQ1RFRBACEhAKDFJFQ09OTkVDVElORxAD');

@$core.Deprecated('Use authRequestDescriptor instead')
const AuthRequest$json = {
  '1': 'AuthRequest',
  '2': [
    {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `AuthRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authRequestDescriptor = $convert.base64Decode(
    'CgtBdXRoUmVxdWVzdBIaCgh1c2VybmFtZRgBIAEoCVIIdXNlcm5hbWUSGgoIcGFzc3dvcmQYAi'
    'ABKAlSCHBhc3N3b3Jk');

@$core.Deprecated('Use authResponseDescriptor instead')
const AuthResponse$json = {
  '1': 'AuthResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'token', '3': 2, '4': 1, '5': 9, '10': 'token'},
    {'1': 'user_id', '3': 3, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'username', '3': 4, '4': 1, '5': 9, '10': 'username'},
    {'1': 'message', '3': 5, '4': 1, '5': 9, '10': 'message'},
    {'1': 'rating', '3': 6, '4': 1, '5': 5, '10': 'rating'},
  ],
};

/// Descriptor for `AuthResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authResponseDescriptor = $convert.base64Decode(
    'CgxBdXRoUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIUCgV0b2tlbhgCIAEoCV'
    'IFdG9rZW4SFwoHdXNlcl9pZBgDIAEoCVIGdXNlcklkEhoKCHVzZXJuYW1lGAQgASgJUgh1c2Vy'
    'bmFtZRIYCgdtZXNzYWdlGAUgASgJUgdtZXNzYWdlEhYKBnJhdGluZxgGIAEoBVIGcmF0aW5n');

@$core.Deprecated('Use playerDescriptor instead')
const Player$json = {
  '1': 'Player',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {'1': 'rating', '3': 3, '4': 1, '5': 5, '10': 'rating'},
    {'1': 'status', '3': 4, '4': 1, '5': 14, '6': '.quiz.PlayerStatus', '10': 'status'},
  ],
};

/// Descriptor for `Player`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List playerDescriptor = $convert.base64Decode(
    'CgZQbGF5ZXISFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEhoKCHVzZXJuYW1lGAIgASgJUgh1c2'
    'VybmFtZRIWCgZyYXRpbmcYAyABKAVSBnJhdGluZxIqCgZzdGF0dXMYBCABKA4yEi5xdWl6LlBs'
    'YXllclN0YXR1c1IGc3RhdHVz');

@$core.Deprecated('Use questionDescriptor instead')
const Question$json = {
  '1': 'Question',
  '2': [
    {'1': 'question_id', '3': 1, '4': 1, '5': 9, '10': 'questionId'},
    {'1': 'text', '3': 2, '4': 1, '5': 9, '10': 'text'},
    {'1': 'options', '3': 3, '4': 3, '5': 9, '10': 'options'},
    {'1': 'difficulty', '3': 4, '4': 1, '5': 14, '6': '.quiz.Difficulty', '10': 'difficulty'},
    {'1': 'topic', '3': 5, '4': 1, '5': 9, '10': 'topic'},
    {'1': 'time_limit_ms', '3': 6, '4': 1, '5': 5, '10': 'timeLimitMs'},
  ],
};

/// Descriptor for `Question`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List questionDescriptor = $convert.base64Decode(
    'CghRdWVzdGlvbhIfCgtxdWVzdGlvbl9pZBgBIAEoCVIKcXVlc3Rpb25JZBISCgR0ZXh0GAIgAS'
    'gJUgR0ZXh0EhgKB29wdGlvbnMYAyADKAlSB29wdGlvbnMSMAoKZGlmZmljdWx0eRgEIAEoDjIQ'
    'LnF1aXouRGlmZmljdWx0eVIKZGlmZmljdWx0eRIUCgV0b3BpYxgFIAEoCVIFdG9waWMSIgoNdG'
    'ltZV9saW1pdF9tcxgGIAEoBVILdGltZUxpbWl0TXM=');

@$core.Deprecated('Use playerScoreDescriptor instead')
const PlayerScore$json = {
  '1': 'PlayerScore',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {'1': 'score', '3': 3, '4': 1, '5': 5, '10': 'score'},
    {'1': 'rank', '3': 4, '4': 1, '5': 5, '10': 'rank'},
    {'1': 'answers_correct', '3': 5, '4': 1, '5': 5, '10': 'answersCorrect'},
    {'1': 'avg_response_ms', '3': 6, '4': 1, '5': 5, '10': 'avgResponseMs'},
    {'1': 'is_connected', '3': 7, '4': 1, '5': 8, '10': 'isConnected'},
  ],
};

/// Descriptor for `PlayerScore`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List playerScoreDescriptor = $convert.base64Decode(
    'CgtQbGF5ZXJTY29yZRIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSGgoIdXNlcm5hbWUYAiABKA'
    'lSCHVzZXJuYW1lEhQKBXNjb3JlGAMgASgFUgVzY29yZRISCgRyYW5rGAQgASgFUgRyYW5rEicK'
    'D2Fuc3dlcnNfY29ycmVjdBgFIAEoBVIOYW5zd2Vyc0NvcnJlY3QSJgoPYXZnX3Jlc3BvbnNlX2'
    '1zGAYgASgFUg1hdmdSZXNwb25zZU1zEiEKDGlzX2Nvbm5lY3RlZBgHIAEoCFILaXNDb25uZWN0'
    'ZWQ=');

@$core.Deprecated('Use joinRequestDescriptor instead')
const JoinRequest$json = {
  '1': 'JoinRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {'1': 'rating', '3': 3, '4': 1, '5': 5, '10': 'rating'},
  ],
};

/// Descriptor for `JoinRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinRequestDescriptor = $convert.base64Decode(
    'CgtKb2luUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSGgoIdXNlcm5hbWUYAiABKA'
    'lSCHVzZXJuYW1lEhYKBnJhdGluZxgDIAEoBVIGcmF0aW5n');

@$core.Deprecated('Use joinResponseDescriptor instead')
const JoinResponse$json = {
  '1': 'JoinResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'queue_position', '3': 3, '4': 1, '5': 9, '10': 'queuePosition'},
  ],
};

/// Descriptor for `JoinResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinResponseDescriptor = $convert.base64Decode(
    'CgxKb2luUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIYCgdtZXNzYWdlGAIgAS'
    'gJUgdtZXNzYWdlEiUKDnF1ZXVlX3Bvc2l0aW9uGAMgASgJUg1xdWV1ZVBvc2l0aW9u');

@$core.Deprecated('Use leaveRequestDescriptor instead')
const LeaveRequest$json = {
  '1': 'LeaveRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `LeaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List leaveRequestDescriptor = $convert.base64Decode(
    'CgxMZWF2ZVJlcXVlc3QSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklk');

@$core.Deprecated('Use leaveResponseDescriptor instead')
const LeaveResponse$json = {
  '1': 'LeaveResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `LeaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List leaveResponseDescriptor = $convert.base64Decode(
    'Cg1MZWF2ZVJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSGAoHbWVzc2FnZRgCIA'
    'EoCVIHbWVzc2FnZQ==');

@$core.Deprecated('Use subscribeRequestDescriptor instead')
const SubscribeRequest$json = {
  '1': 'SubscribeRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `SubscribeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeRequestDescriptor = $convert.base64Decode(
    'ChBTdWJzY3JpYmVSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZA==');

@$core.Deprecated('Use matchEventDescriptor instead')
const MatchEvent$json = {
  '1': 'MatchEvent',
  '2': [
    {'1': 'match_found', '3': 1, '4': 1, '5': 11, '6': '.quiz.MatchFound', '9': 0, '10': 'matchFound'},
    {'1': 'match_cancelled', '3': 2, '4': 1, '5': 11, '6': '.quiz.MatchCancelled', '9': 0, '10': 'matchCancelled'},
    {'1': 'waiting_update', '3': 3, '4': 1, '5': 11, '6': '.quiz.WaitingUpdate', '9': 0, '10': 'waitingUpdate'},
  ],
  '8': [
    {'1': 'event'},
  ],
};

/// Descriptor for `MatchEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matchEventDescriptor = $convert.base64Decode(
    'CgpNYXRjaEV2ZW50EjMKC21hdGNoX2ZvdW5kGAEgASgLMhAucXVpei5NYXRjaEZvdW5kSABSCm'
    '1hdGNoRm91bmQSPwoPbWF0Y2hfY2FuY2VsbGVkGAIgASgLMhQucXVpei5NYXRjaENhbmNlbGxl'
    'ZEgAUg5tYXRjaENhbmNlbGxlZBI8Cg53YWl0aW5nX3VwZGF0ZRgDIAEoCzITLnF1aXouV2FpdG'
    'luZ1VwZGF0ZUgAUg13YWl0aW5nVXBkYXRlQgcKBWV2ZW50');

@$core.Deprecated('Use matchFoundDescriptor instead')
const MatchFound$json = {
  '1': 'MatchFound',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 9, '10': 'roomId'},
    {'1': 'players', '3': 2, '4': 3, '5': 11, '6': '.quiz.Player', '10': 'players'},
    {'1': 'total_rounds', '3': 3, '4': 1, '5': 5, '10': 'totalRounds'},
  ],
};

/// Descriptor for `MatchFound`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matchFoundDescriptor = $convert.base64Decode(
    'CgpNYXRjaEZvdW5kEhcKB3Jvb21faWQYASABKAlSBnJvb21JZBImCgdwbGF5ZXJzGAIgAygLMg'
    'wucXVpei5QbGF5ZXJSB3BsYXllcnMSIQoMdG90YWxfcm91bmRzGAMgASgFUgt0b3RhbFJvdW5k'
    'cw==');

@$core.Deprecated('Use matchCancelledDescriptor instead')
const MatchCancelled$json = {
  '1': 'MatchCancelled',
  '2': [
    {'1': 'reason', '3': 1, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `MatchCancelled`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matchCancelledDescriptor = $convert.base64Decode(
    'Cg5NYXRjaENhbmNlbGxlZBIWCgZyZWFzb24YASABKAlSBnJlYXNvbg==');

@$core.Deprecated('Use waitingUpdateDescriptor instead')
const WaitingUpdate$json = {
  '1': 'WaitingUpdate',
  '2': [
    {'1': 'players_in_pool', '3': 1, '4': 1, '5': 5, '10': 'playersInPool'},
    {'1': 'estimated_wait_seconds', '3': 2, '4': 1, '5': 5, '10': 'estimatedWaitSeconds'},
  ],
};

/// Descriptor for `WaitingUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List waitingUpdateDescriptor = $convert.base64Decode(
    'Cg1XYWl0aW5nVXBkYXRlEiYKD3BsYXllcnNfaW5fcG9vbBgBIAEoBVINcGxheWVyc0luUG9vbB'
    'I0ChZlc3RpbWF0ZWRfd2FpdF9zZWNvbmRzGAIgASgFUhRlc3RpbWF0ZWRXYWl0U2Vjb25kcw==');

@$core.Deprecated('Use roomRequestDescriptor instead')
const RoomRequest$json = {
  '1': 'RoomRequest',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 9, '10': 'roomId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `RoomRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List roomRequestDescriptor = $convert.base64Decode(
    'CgtSb29tUmVxdWVzdBIXCgdyb29tX2lkGAEgASgJUgZyb29tSWQSFwoHdXNlcl9pZBgCIAEoCV'
    'IGdXNlcklk');

@$core.Deprecated('Use questionsResponseDescriptor instead')
const QuestionsResponse$json = {
  '1': 'QuestionsResponse',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 9, '10': 'roomId'},
    {'1': 'questions', '3': 2, '4': 3, '5': 11, '6': '.quiz.Question', '10': 'questions'},
    {'1': 'total_rounds', '3': 3, '4': 1, '5': 5, '10': 'totalRounds'},
  ],
};

/// Descriptor for `QuestionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List questionsResponseDescriptor = $convert.base64Decode(
    'ChFRdWVzdGlvbnNSZXNwb25zZRIXCgdyb29tX2lkGAEgASgJUgZyb29tSWQSLAoJcXVlc3Rpb2'
    '5zGAIgAygLMg4ucXVpei5RdWVzdGlvblIJcXVlc3Rpb25zEiEKDHRvdGFsX3JvdW5kcxgDIAEo'
    'BVILdG90YWxSb3VuZHM=');

@$core.Deprecated('Use answerRequestDescriptor instead')
const AnswerRequest$json = {
  '1': 'AnswerRequest',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 9, '10': 'roomId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'round_number', '3': 3, '4': 1, '5': 5, '10': 'roundNumber'},
    {'1': 'question_id', '3': 4, '4': 1, '5': 9, '10': 'questionId'},
    {'1': 'answer_index', '3': 5, '4': 1, '5': 5, '10': 'answerIndex'},
    {'1': 'submitted_at_ms', '3': 6, '4': 1, '5': 3, '10': 'submittedAtMs'},
  ],
};

/// Descriptor for `AnswerRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List answerRequestDescriptor = $convert.base64Decode(
    'Cg1BbnN3ZXJSZXF1ZXN0EhcKB3Jvb21faWQYASABKAlSBnJvb21JZBIXCgd1c2VyX2lkGAIgAS'
    'gJUgZ1c2VySWQSIQoMcm91bmRfbnVtYmVyGAMgASgFUgtyb3VuZE51bWJlchIfCgtxdWVzdGlv'
    'bl9pZBgEIAEoCVIKcXVlc3Rpb25JZBIhCgxhbnN3ZXJfaW5kZXgYBSABKAVSC2Fuc3dlckluZG'
    'V4EiYKD3N1Ym1pdHRlZF9hdF9tcxgGIAEoA1INc3VibWl0dGVkQXRNcw==');

@$core.Deprecated('Use answerAckDescriptor instead')
const AnswerAck$json = {
  '1': 'AnswerAck',
  '2': [
    {'1': 'received', '3': 1, '4': 1, '5': 8, '10': 'received'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `AnswerAck`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List answerAckDescriptor = $convert.base64Decode(
    'CglBbnN3ZXJBY2sSGgoIcmVjZWl2ZWQYASABKAhSCHJlY2VpdmVkEhgKB21lc3NhZ2UYAiABKA'
    'lSB21lc3NhZ2U=');

@$core.Deprecated('Use streamRequestDescriptor instead')
const StreamRequest$json = {
  '1': 'StreamRequest',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 9, '10': 'roomId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `StreamRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamRequestDescriptor = $convert.base64Decode(
    'Cg1TdHJlYW1SZXF1ZXN0EhcKB3Jvb21faWQYASABKAlSBnJvb21JZBIXCgd1c2VyX2lkGAIgAS'
    'gJUgZ1c2VySWQ=');

@$core.Deprecated('Use gameEventDescriptor instead')
const GameEvent$json = {
  '1': 'GameEvent',
  '2': [
    {'1': 'question', '3': 1, '4': 1, '5': 11, '6': '.quiz.QuestionBroadcast', '9': 0, '10': 'question'},
    {'1': 'leaderboard', '3': 2, '4': 1, '5': 11, '6': '.quiz.LeaderboardUpdate', '9': 0, '10': 'leaderboard'},
    {'1': 'round_result', '3': 3, '4': 1, '5': 11, '6': '.quiz.RoundResult', '9': 0, '10': 'roundResult'},
    {'1': 'match_end', '3': 4, '4': 1, '5': 11, '6': '.quiz.MatchEnd', '9': 0, '10': 'matchEnd'},
    {'1': 'player_joined', '3': 5, '4': 1, '5': 11, '6': '.quiz.PlayerJoined', '9': 0, '10': 'playerJoined'},
    {'1': 'timer_sync', '3': 6, '4': 1, '5': 11, '6': '.quiz.TimerSync', '9': 0, '10': 'timerSync'},
  ],
  '8': [
    {'1': 'event'},
  ],
};

/// Descriptor for `GameEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gameEventDescriptor = $convert.base64Decode(
    'CglHYW1lRXZlbnQSNQoIcXVlc3Rpb24YASABKAsyFy5xdWl6LlF1ZXN0aW9uQnJvYWRjYXN0SA'
    'BSCHF1ZXN0aW9uEjsKC2xlYWRlcmJvYXJkGAIgASgLMhcucXVpei5MZWFkZXJib2FyZFVwZGF0'
    'ZUgAUgtsZWFkZXJib2FyZBI2Cgxyb3VuZF9yZXN1bHQYAyABKAsyES5xdWl6LlJvdW5kUmVzdW'
    'x0SABSC3JvdW5kUmVzdWx0Ei0KCW1hdGNoX2VuZBgEIAEoCzIOLnF1aXouTWF0Y2hFbmRIAFII'
    'bWF0Y2hFbmQSOQoNcGxheWVyX2pvaW5lZBgFIAEoCzISLnF1aXouUGxheWVySm9pbmVkSABSDH'
    'BsYXllckpvaW5lZBIwCgp0aW1lcl9zeW5jGAYgASgLMg8ucXVpei5UaW1lclN5bmNIAFIJdGlt'
    'ZXJTeW5jQgcKBWV2ZW50');

@$core.Deprecated('Use questionBroadcastDescriptor instead')
const QuestionBroadcast$json = {
  '1': 'QuestionBroadcast',
  '2': [
    {'1': 'round_number', '3': 1, '4': 1, '5': 5, '10': 'roundNumber'},
    {'1': 'question', '3': 2, '4': 1, '5': 11, '6': '.quiz.Question', '10': 'question'},
    {'1': 'deadline_ms', '3': 3, '4': 1, '5': 3, '10': 'deadlineMs'},
  ],
};

/// Descriptor for `QuestionBroadcast`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List questionBroadcastDescriptor = $convert.base64Decode(
    'ChFRdWVzdGlvbkJyb2FkY2FzdBIhCgxyb3VuZF9udW1iZXIYASABKAVSC3JvdW5kTnVtYmVyEi'
    'oKCHF1ZXN0aW9uGAIgASgLMg4ucXVpei5RdWVzdGlvblIIcXVlc3Rpb24SHwoLZGVhZGxpbmVf'
    'bXMYAyABKANSCmRlYWRsaW5lTXM=');

@$core.Deprecated('Use leaderboardUpdateDescriptor instead')
const LeaderboardUpdate$json = {
  '1': 'LeaderboardUpdate',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 9, '10': 'roomId'},
    {'1': 'round_number', '3': 2, '4': 1, '5': 5, '10': 'roundNumber'},
    {'1': 'scores', '3': 3, '4': 3, '5': 11, '6': '.quiz.PlayerScore', '10': 'scores'},
  ],
};

/// Descriptor for `LeaderboardUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List leaderboardUpdateDescriptor = $convert.base64Decode(
    'ChFMZWFkZXJib2FyZFVwZGF0ZRIXCgdyb29tX2lkGAEgASgJUgZyb29tSWQSIQoMcm91bmRfbn'
    'VtYmVyGAIgASgFUgtyb3VuZE51bWJlchIpCgZzY29yZXMYAyADKAsyES5xdWl6LlBsYXllclNj'
    'b3JlUgZzY29yZXM=');

@$core.Deprecated('Use roundResultDescriptor instead')
const RoundResult$json = {
  '1': 'RoundResult',
  '2': [
    {'1': 'round_number', '3': 1, '4': 1, '5': 5, '10': 'roundNumber'},
    {'1': 'question_id', '3': 2, '4': 1, '5': 9, '10': 'questionId'},
    {'1': 'correct_index', '3': 3, '4': 1, '5': 5, '10': 'correctIndex'},
    {'1': 'scores', '3': 4, '4': 3, '5': 11, '6': '.quiz.PlayerScore', '10': 'scores'},
    {'1': 'fastest_user_id', '3': 5, '4': 1, '5': 9, '10': 'fastestUserId'},
  ],
};

/// Descriptor for `RoundResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List roundResultDescriptor = $convert.base64Decode(
    'CgtSb3VuZFJlc3VsdBIhCgxyb3VuZF9udW1iZXIYASABKAVSC3JvdW5kTnVtYmVyEh8KC3F1ZX'
    'N0aW9uX2lkGAIgASgJUgpxdWVzdGlvbklkEiMKDWNvcnJlY3RfaW5kZXgYAyABKAVSDGNvcnJl'
    'Y3RJbmRleBIpCgZzY29yZXMYBCADKAsyES5xdWl6LlBsYXllclNjb3JlUgZzY29yZXMSJgoPZm'
    'FzdGVzdF91c2VyX2lkGAUgASgJUg1mYXN0ZXN0VXNlcklk');

@$core.Deprecated('Use matchEndDescriptor instead')
const MatchEnd$json = {
  '1': 'MatchEnd',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 9, '10': 'roomId'},
    {'1': 'winner_user_id', '3': 2, '4': 1, '5': 9, '10': 'winnerUserId'},
    {'1': 'winner_username', '3': 3, '4': 1, '5': 9, '10': 'winnerUsername'},
    {'1': 'final_scores', '3': 4, '4': 3, '5': 11, '6': '.quiz.PlayerScore', '10': 'finalScores'},
    {'1': 'total_rounds', '3': 5, '4': 1, '5': 5, '10': 'totalRounds'},
    {'1': 'duration_seconds', '3': 6, '4': 1, '5': 5, '10': 'durationSeconds'},
  ],
};

/// Descriptor for `MatchEnd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matchEndDescriptor = $convert.base64Decode(
    'CghNYXRjaEVuZBIXCgdyb29tX2lkGAEgASgJUgZyb29tSWQSJAoOd2lubmVyX3VzZXJfaWQYAi'
    'ABKAlSDHdpbm5lclVzZXJJZBInCg93aW5uZXJfdXNlcm5hbWUYAyABKAlSDndpbm5lclVzZXJu'
    'YW1lEjQKDGZpbmFsX3Njb3JlcxgEIAMoCzIRLnF1aXouUGxheWVyU2NvcmVSC2ZpbmFsU2Nvcm'
    'VzEiEKDHRvdGFsX3JvdW5kcxgFIAEoBVILdG90YWxSb3VuZHMSKQoQZHVyYXRpb25fc2Vjb25k'
    'cxgGIAEoBVIPZHVyYXRpb25TZWNvbmRz');

@$core.Deprecated('Use playerJoinedDescriptor instead')
const PlayerJoined$json = {
  '1': 'PlayerJoined',
  '2': [
    {'1': 'player', '3': 1, '4': 1, '5': 11, '6': '.quiz.Player', '10': 'player'},
    {'1': 'round_number', '3': 2, '4': 1, '5': 5, '10': 'roundNumber'},
    {'1': 'state', '3': 3, '4': 1, '5': 14, '6': '.quiz.MatchState', '10': 'state'},
  ],
};

/// Descriptor for `PlayerJoined`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List playerJoinedDescriptor = $convert.base64Decode(
    'CgxQbGF5ZXJKb2luZWQSJAoGcGxheWVyGAEgASgLMgwucXVpei5QbGF5ZXJSBnBsYXllchIhCg'
    'xyb3VuZF9udW1iZXIYAiABKAVSC3JvdW5kTnVtYmVyEiYKBXN0YXRlGAMgASgOMhAucXVpei5N'
    'YXRjaFN0YXRlUgVzdGF0ZQ==');

@$core.Deprecated('Use timerSyncDescriptor instead')
const TimerSync$json = {
  '1': 'TimerSync',
  '2': [
    {'1': 'round_number', '3': 1, '4': 1, '5': 5, '10': 'roundNumber'},
    {'1': 'server_time_ms', '3': 2, '4': 1, '5': 3, '10': 'serverTimeMs'},
    {'1': 'deadline_ms', '3': 3, '4': 1, '5': 3, '10': 'deadlineMs'},
  ],
};

/// Descriptor for `TimerSync`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timerSyncDescriptor = $convert.base64Decode(
    'CglUaW1lclN5bmMSIQoMcm91bmRfbnVtYmVyGAEgASgFUgtyb3VuZE51bWJlchIkCg5zZXJ2ZX'
    'JfdGltZV9tcxgCIAEoA1IMc2VydmVyVGltZU1zEh8KC2RlYWRsaW5lX21zGAMgASgDUgpkZWFk'
    'bGluZU1z');

@$core.Deprecated('Use scoreRequestDescriptor instead')
const ScoreRequest$json = {
  '1': 'ScoreRequest',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 9, '10': 'roomId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'round_number', '3': 3, '4': 1, '5': 5, '10': 'roundNumber'},
    {'1': 'question_id', '3': 4, '4': 1, '5': 9, '10': 'questionId'},
    {'1': 'answer_index', '3': 5, '4': 1, '5': 5, '10': 'answerIndex'},
    {'1': 'submitted_at_ms', '3': 6, '4': 1, '5': 3, '10': 'submittedAtMs'},
    {'1': 'round_started_at_ms', '3': 7, '4': 1, '5': 3, '10': 'roundStartedAtMs'},
  ],
};

/// Descriptor for `ScoreRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scoreRequestDescriptor = $convert.base64Decode(
    'CgxTY29yZVJlcXVlc3QSFwoHcm9vbV9pZBgBIAEoCVIGcm9vbUlkEhcKB3VzZXJfaWQYAiABKA'
    'lSBnVzZXJJZBIhCgxyb3VuZF9udW1iZXIYAyABKAVSC3JvdW5kTnVtYmVyEh8KC3F1ZXN0aW9u'
    'X2lkGAQgASgJUgpxdWVzdGlvbklkEiEKDGFuc3dlcl9pbmRleBgFIAEoBVILYW5zd2VySW5kZX'
    'gSJgoPc3VibWl0dGVkX2F0X21zGAYgASgDUg1zdWJtaXR0ZWRBdE1zEi0KE3JvdW5kX3N0YXJ0'
    'ZWRfYXRfbXMYByABKANSEHJvdW5kU3RhcnRlZEF0TXM=');

@$core.Deprecated('Use scoreResponseDescriptor instead')
const ScoreResponse$json = {
  '1': 'ScoreResponse',
  '2': [
    {'1': 'is_correct', '3': 1, '4': 1, '5': 8, '10': 'isCorrect'},
    {'1': 'points_awarded', '3': 2, '4': 1, '5': 5, '10': 'pointsAwarded'},
    {'1': 'total_score', '3': 3, '4': 1, '5': 5, '10': 'totalScore'},
    {'1': 'speed_bonus', '3': 4, '4': 1, '5': 5, '10': 'speedBonus'},
    {'1': 'new_rank', '3': 5, '4': 1, '5': 5, '10': 'newRank'},
  ],
};

/// Descriptor for `ScoreResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scoreResponseDescriptor = $convert.base64Decode(
    'Cg1TY29yZVJlc3BvbnNlEh0KCmlzX2NvcnJlY3QYASABKAhSCWlzQ29ycmVjdBIlCg5wb2ludH'
    'NfYXdhcmRlZBgCIAEoBVINcG9pbnRzQXdhcmRlZBIfCgt0b3RhbF9zY29yZRgDIAEoBVIKdG90'
    'YWxTY29yZRIfCgtzcGVlZF9ib251cxgEIAEoBVIKc3BlZWRCb251cxIZCghuZXdfcmFuaxgFIA'
    'EoBVIHbmV3UmFuaw==');

@$core.Deprecated('Use leaderboardRequestDescriptor instead')
const LeaderboardRequest$json = {
  '1': 'LeaderboardRequest',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 9, '10': 'roomId'},
  ],
};

/// Descriptor for `LeaderboardRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List leaderboardRequestDescriptor = $convert.base64Decode(
    'ChJMZWFkZXJib2FyZFJlcXVlc3QSFwoHcm9vbV9pZBgBIAEoCVIGcm9vbUlk');

@$core.Deprecated('Use leaderboardResponseDescriptor instead')
const LeaderboardResponse$json = {
  '1': 'LeaderboardResponse',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 9, '10': 'roomId'},
    {'1': 'round_number', '3': 2, '4': 1, '5': 5, '10': 'roundNumber'},
    {'1': 'scores', '3': 3, '4': 3, '5': 11, '6': '.quiz.PlayerScore', '10': 'scores'},
  ],
};

/// Descriptor for `LeaderboardResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List leaderboardResponseDescriptor = $convert.base64Decode(
    'ChNMZWFkZXJib2FyZFJlc3BvbnNlEhcKB3Jvb21faWQYASABKAlSBnJvb21JZBIhCgxyb3VuZF'
    '9udW1iZXIYAiABKAVSC3JvdW5kTnVtYmVyEikKBnNjb3JlcxgDIAMoCzIRLnF1aXouUGxheWVy'
    'U2NvcmVSBnNjb3Jlcw==');


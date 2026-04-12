import 'package:flutter/material.dart';

// ─────────────────────────────────────────
// APP COLORS — single source of truth
// Import this file in every screen instead of redefining locally.
// ─────────────────────────────────────────

const appCoral   = Color(0xFFC96442);
const appBg      = Color(0xFF0D0D1A);
const appSurface = Color(0xFF1A1A2E);
const appGold    = Color(0xFFFFB830);
const appSilver  = Color(0xFFB0BEC5);
const appBronze  = Color(0xFFCD7F32);
const appGreen   = Color(0xFF2ECC71);
const appRed     = Color(0xFFE74C3C);

// Legacy aliases — kept so existing code using kCoral etc. still compiles.
const kCoral   = appCoral;
const kBg      = appBg;
const kSurface = appSurface;
const kGold    = appGold;
const kSilver  = appSilver;
const kBronze  = appBronze;
const kGreen   = appGreen;
const kRed     = appRed;

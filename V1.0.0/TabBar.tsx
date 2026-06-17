/**
 * TailTopia · Tab Bar
 *
 * Spec:   icon-system.md V1.0.0
 * Tokens: tokens.json / tokens.css (violet-500 palette)
 * Icons:  phosphor-react-native — regular (inactive) · fill (active)
 * FX:     Neo-Brutalism · Pop Art offset (red-500 +3/+3, native-driven)
 *
 * Usage:
 *   <Tab.Navigator
 *     tabBar={props => (
 *       <TailTopiaTabBar
 *         {...props}
 *         isAuthenticated={auth.isSignedIn}
 *         hasUnreadConsultation={unread}
 *         onAuthRequired={name => showLoginSheet(name)}
 *       />
 *     )}
 *   >
 *     <Tab.Screen name="Home"        ... />
 *     <Tab.Screen name="Passport"    ... />
 *     <Tab.Screen name="Create"      ... />  ← [+] slot
 *     <Tab.Screen name="Konsultasi"  ... />
 *     <Tab.Screen name="Profile"     ... />
 *   </Tab.Navigator>
 *
 * Android note: the [+] button protrudes above the tab bar via marginTop.
 * If elevation clips the button on Android, wrap the tab bar in a View with
 * zIndex: 1 and ensure the navigator screen content has a lower zIndex.
 */

import React, {
  useRef,
  useEffect,
  useState,
  useCallback,
  type ComponentType,
} from 'react';
import {
  View,
  Pressable,
  Animated,
  Easing,
  StyleSheet,
  Text,
  AccessibilityInfo,
  Platform,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import {
  House,
  BookOpen,
  Plus,
  Stethoscope,
  User,
} from 'phosphor-react-native';
import type { BottomTabBarProps } from '@react-navigation/bottom-tabs';
import type { IconProps } from 'phosphor-react-native';

// ─────────────────────────────────────────────────────────────────────────────
// Design Tokens  (mirror of tokens.json — no raw hex outside this block)
// ─────────────────────────────────────────────────────────────────────────────

const T = {
  // Colors — semantic names match tokens.css vars
  violet500:        '#7D16FF',  // --color-brand-primary   · active fill
  red500:           '#F0425A',  // --color-error           · Pop Art offset
  ink700:           '#544864',  // --color-text-primary    · inactive icon
  grey500:          '#A7A7A7',  // --color-text-tertiary   · inactive label
  white:            '#FFFFFF',  // --color-bg-surface      · tab bar bg
  shadowNav:        '#162233',  // neutral navy ink
  shadowBrand:      '#7D16FF',  // violet glow

  // Icon system (icon-system.md §4 / §5 / §12)
  iconSize:          26,         // pt
  offsetPx:           3,         // pt — Pop Art X / Y shift
  containerSize:     32,         // pt — double-layer bounding box

  inactiveOpacity:  0.55,

  // Motion — --duration-fast / --easing-enter
  durationFast:     150,         // ms
  durationPress:    100,         // ms

  // Layout
  TAB_HEIGHT:        49,         // pt — content row (safe area added separately)
  PLUS_SIZE:         56,         // pt — circle diameter
  PLUS_MT:          -14,         // pt — negative marginTop → protrudes above bar
  RADIUS_TOP:        32,         // pt — --radius-3xl, top corners only
  LABEL_SIZE:        10,         // pt — --text-xs
  BADGE_SIZE:         8,         // pt

  // Press feedback
  pressScale:       0.92,
  plusPressScale:   0.93,
} as const;

// ─────────────────────────────────────────────────────────────────────────────
// Route → Config Map  (FR-19: Home · Passport · [+] · Konsultasi · Profile)
// ─────────────────────────────────────────────────────────────────────────────

type PhosphorIcon = ComponentType<IconProps>;

interface RouteConfig {
  label:        string;
  a11yLabel:    string;
  authRequired: boolean;
  Icon:         PhosphorIcon;
  isPlus?:      true;
}

const ROUTES: Record<string, RouteConfig> = {
  Home: {
    label:        'Beranda',
    a11yLabel:    'Beranda',
    authRequired: false,
    Icon:         House,
  },
  Passport: {
    label:        'Paspor',
    a11yLabel:    'Paspor Tumbuh Kembang',
    authRequired: true,
    Icon:         BookOpen,
  },
  Create: {
    label:        '',
    a11yLabel:    'Buat postingan baru',
    authRequired: true,
    Icon:         Plus,
    isPlus:       true,
  },
  Konsultasi: {
    label:        'Konsultasi',
    a11yLabel:    'Konsultasi',
    authRequired: true,
    Icon:         Stethoscope,
  },
  Profile: {
    label:        'Profil',
    a11yLabel:    'Profil saya',
    authRequired: true,
    Icon:         User,
  },
};

// ─────────────────────────────────────────────────────────────────────────────
// Hook — Reduced Motion  (icon-system.md §7 · WCAG §1.4.3)
// ─────────────────────────────────────────────────────────────────────────────

function useReducedMotion(): boolean {
  const [enabled, setEnabled] = useState(false);

  useEffect(() => {
    let cancelled = false;
    AccessibilityInfo.isReduceMotionEnabled().then(v => {
      if (!cancelled) setEnabled(v);
    });
    const sub = AccessibilityInfo.addEventListener('reduceMotionChanged', setEnabled);
    return () => {
      cancelled = true;
      sub.remove();
    };
  }, []);

  return enabled;
}

// ─────────────────────────────────────────────────────────────────────────────
// PopArtIcon  (icon-system.md §4 / §5)
//
//  Inactive → single outline layer, opacity 0.55
//  Active   → two absolute layers:
//               [Z-bottom] red-500 fill, offset (+3, +3)  ← Pop Art shadow
//               [Z-top]    violet-500 fill, origin (0, 0)
//             Right/bottom edge of red icon peeks out 3pt
//             → simulates silk-screen registration offset
// ─────────────────────────────────────────────────────────────────────────────

interface PopArtIconProps {
  Icon:       PhosphorIcon;
  isActive:   boolean;
  offsetAnim: Animated.Value;  // 0 → 1, native-driven: offset layer opacity
  mainOpAnim: Animated.Value;  // 0.55 → 1.0, native-driven: outline opacity
}

function PopArtIcon({ Icon, isActive, offsetAnim, mainOpAnim }: PopArtIconProps) {
  if (isActive) {
    return (
      <View style={styles.iconContainer}>
        {/* Layer 1 — red offset (Z-bottom, +3/+3) */}
        <Animated.View
          style={[styles.layerOffset, { opacity: offsetAnim }]}
          pointerEvents="none"
        >
          <Icon weight="fill" size={T.iconSize} color={T.red500} />
        </Animated.View>

        {/* Layer 2 — violet main (Z-top, origin) */}
        <View style={styles.layerMain} pointerEvents="none">
          <Icon weight="fill" size={T.iconSize} color={T.violet500} />
        </View>
      </View>
    );
  }

  return (
    <Animated.View
      style={[styles.iconContainer, { opacity: mainOpAnim }]}
      pointerEvents="none"
    >
      <Icon weight="regular" size={T.iconSize} color={T.ink700} />
    </Animated.View>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// PlusButton  (icon-system.md §6 — no Pop Art, always clean)
// ─────────────────────────────────────────────────────────────────────────────

interface PlusButtonProps {
  onPress:       () => void;
  reducedMotion: boolean;
}

function PlusButton({ onPress, reducedMotion }: PlusButtonProps) {
  const scaleAnim = useRef(new Animated.Value(1)).current;

  const onPressIn = useCallback(() => {
    Animated.timing(scaleAnim, {
      toValue:         T.plusPressScale,
      duration:        reducedMotion ? 0 : T.durationPress,
      easing:          Easing.out(Easing.quad),
      useNativeDriver: true,
    }).start();
  }, [scaleAnim, reducedMotion]);

  const onPressOut = useCallback(() => {
    Animated.spring(scaleAnim, {
      toValue:         1,
      bounciness:      6,
      useNativeDriver: true,
    }).start();
  }, [scaleAnim]);

  return (
    <View style={styles.plusWrapper}>
      <Pressable
        onPress={onPress}
        onPressIn={onPressIn}
        onPressOut={onPressOut}
        accessibilityRole="button"
        accessibilityLabel="Buat postingan baru"
      >
        <Animated.View
          style={[styles.plusButton, { transform: [{ scale: scaleAnim }] }]}
        >
          <Plus weight="bold" size={28} color={T.white} />
        </Animated.View>
      </Pressable>
    </View>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TabItem  (icon-system.md §7 — state machine + animation)
// ─────────────────────────────────────────────────────────────────────────────

interface TabItemProps {
  config:        RouteConfig;
  routeName:     string;
  isActive:      boolean;
  showBadge:     boolean;
  onPress:       () => void;
  reducedMotion: boolean;
}

function TabItem({
  config,
  routeName,
  isActive,
  showBadge,
  onPress,
  reducedMotion,
}: TabItemProps) {
  // offsetAnim: offset layer opacity (0 → 1), native driver
  const offsetAnim = useRef(new Animated.Value(isActive ? 1 : 0)).current;
  // mainOpAnim: outline icon opacity (0.55 → 1.0), native driver
  const mainOpAnim = useRef(
    new Animated.Value(isActive ? 1 : T.inactiveOpacity),
  ).current;
  // scaleAnim: press feedback, native driver
  const scaleAnim = useRef(new Animated.Value(1)).current;

  useEffect(() => {
    const dur = reducedMotion ? 0 : T.durationFast;
    Animated.parallel([
      Animated.timing(offsetAnim, {
        toValue:         isActive ? 1 : 0,
        duration:        dur,
        easing:          Easing.out(Easing.quad),
        useNativeDriver: true,
      }),
      Animated.timing(mainOpAnim, {
        toValue:         isActive ? 1 : T.inactiveOpacity,
        duration:        dur,
        easing:          Easing.out(Easing.quad),
        useNativeDriver: true,
      }),
    ]).start();
  }, [isActive, reducedMotion, offsetAnim, mainOpAnim]);

  const onPressIn = useCallback(() => {
    Animated.timing(scaleAnim, {
      toValue:         T.pressScale,
      duration:        reducedMotion ? 0 : T.durationPress,
      easing:          Easing.out(Easing.quad),
      useNativeDriver: true,
    }).start();
  }, [scaleAnim, reducedMotion]);

  const onPressOut = useCallback(() => {
    Animated.spring(scaleAnim, {
      toValue:         1,
      bounciness:      6,
      useNativeDriver: true,
    }).start();
  }, [scaleAnim]);

  const a11yLabel =
    routeName === 'Konsultasi' && showBadge
      ? `${config.a11yLabel}, ada pesan baru dari dokter hewan`
      : config.a11yLabel;

  return (
    <Pressable
      onPress={onPress}
      onPressIn={onPressIn}
      onPressOut={onPressOut}
      style={styles.tabItem}
      accessibilityRole="tab"
      accessibilityLabel={a11yLabel}
      accessibilityState={{ selected: isActive }}
      hitSlop={{ top: 6, bottom: 6, left: 4, right: 4 }}
    >
      <Animated.View
        style={[styles.tabContent, { transform: [{ scale: scaleAnim }] }]}
      >
        {/* Icon + badge wrapper */}
        <View style={styles.iconWrapper}>
          <PopArtIcon
            Icon={config.Icon}
            isActive={isActive}
            offsetAnim={offsetAnim}
            mainOpAnim={mainOpAnim}
          />
          {showBadge && <View style={styles.badge} />}
        </View>

        {/* Label (icon-system.md §9 — 10pt, grey500 / violet500) */}
        <Text
          style={[
            styles.label,
            isActive ? styles.labelActive : styles.labelInactive,
          ]}
          numberOfLines={1}
        >
          {config.label}
        </Text>
      </Animated.View>
    </Pressable>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TailTopiaTabBar — Main Export  (React Navigation compatible)
// ─────────────────────────────────────────────────────────────────────────────

export interface TailTopiaTabBarProps extends BottomTabBarProps {
  /** Show red dot on Konsultasi tab when vet has unread replies (FR-19) */
  hasUnreadConsultation?: boolean;
  /** Called when unauthenticated user taps an auth-required tab (FR-0C) */
  onAuthRequired?: (routeName: string) => void;
  /** Controls auth-gate logic; defaults to true (skip gate if not provided) */
  isAuthenticated?: boolean;
}

export default function TailTopiaTabBar({
  state,
  navigation,
  hasUnreadConsultation = false,
  onAuthRequired,
  isAuthenticated = true,
}: TailTopiaTabBarProps) {
  const insets        = useSafeAreaInsets();
  const reducedMotion = useReducedMotion();

  const handlePress = useCallback(
    (routeName: string, routeKey: string) => {
      const cfg = ROUTES[routeName];
      if (!cfg) return;

      if (!isAuthenticated && cfg.authRequired) {
        onAuthRequired?.(routeName);
        return;
      }

      const event = navigation.emit({
        type:              'tabPress',
        target:            routeKey,
        canPreventDefault: true,
      });

      if (!event.defaultPrevented) {
        navigation.navigate({ name: routeName, merge: true } as never);
      }
    },
    [isAuthenticated, navigation, onAuthRequired],
  );

  return (
    <View
      style={[styles.container, { paddingBottom: insets.bottom }]}
    >
      {state.routes.map((route, index) => {
        const cfg = ROUTES[route.name];
        if (!cfg) return null;

        const onPress = () => handlePress(route.name, route.key);

        if (cfg.isPlus) {
          return (
            <PlusButton
              key={route.key}
              onPress={onPress}
              reducedMotion={reducedMotion}
            />
          );
        }

        return (
          <TabItem
            key={route.key}
            config={cfg}
            routeName={route.name}
            isActive={state.index === index}
            showBadge={route.name === 'Konsultasi' && hasUnreadConsultation}
            onPress={onPress}
            reducedMotion={reducedMotion}
          />
        );
      })}
    </View>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Styles
// ─────────────────────────────────────────────────────────────────────────────

const styles = StyleSheet.create({
  // ── Tab Bar Container ──────────────────────────────────────────────────────
  container: {
    flexDirection:        'row',
    alignItems:           'center',
    backgroundColor:       T.white,
    height:                T.TAB_HEIGHT,
    borderTopLeftRadius:   T.RADIUS_TOP,
    borderTopRightRadius:  T.RADIUS_TOP,
    overflow:             'visible',       // allow [+] to protrude above
    // upward shadow (--shadow-md, offset flipped vertical)
    shadowColor:           T.shadowNav,
    shadowOffset:          { width: 0, height: -4 },
    shadowOpacity:         0.06,
    shadowRadius:          12,
    elevation:             8,
  },

  // ── Regular Tab Slot ───────────────────────────────────────────────────────
  tabItem: {
    flex:           1,
    height:         T.TAB_HEIGHT,
    alignItems:     'center',
    justifyContent: 'center',
  },
  tabContent: {
    alignItems:     'center',
    justifyContent: 'center',
    gap:             2,
  },

  // ── Icon bounding box (holds both outline and Pop Art layers) ──────────────
  iconWrapper: {
    width:          T.containerSize,
    height:         T.containerSize,
    alignItems:     'center',
    justifyContent: 'center',
  },
  // Shared container for both inactive (single) and active (double-layer)
  iconContainer: {
    width:    T.containerSize,
    height:   T.containerSize,
    overflow: 'visible',         // offset layer must not be clipped
  },

  // ── Pop Art Layers ─────────────────────────────────────────────────────────
  // red-500 fill, offset +3/+3 — Z-bottom (rendered first)
  layerOffset: {
    position: 'absolute',
    top:       T.offsetPx,       // +3pt down
    left:      T.offsetPx,       // +3pt right
  },
  // violet-500 fill, origin — Z-top (rendered second, covers offset)
  layerMain: {
    position: 'absolute',
    top:       0,
    left:      0,
  },

  // ── Badge (Konsultasi unread dot) ─────────────────────────────────────────
  badge: {
    position:        'absolute',
    top:             -2,
    right:           -4,
    width:            T.BADGE_SIZE,
    height:           T.BADGE_SIZE,
    borderRadius:     T.BADGE_SIZE / 2,
    backgroundColor:  T.red500,
  },

  // ── Label ──────────────────────────────────────────────────────────────────
  // Poppins must be loaded (expo-font or react-native-asset).
  // Android requires the exact variant filename (Poppins-Regular etc.).
  label: {
    fontSize:   T.LABEL_SIZE,
    fontFamily: Platform.select({
      ios:     'Poppins',
      android: 'Poppins-Regular',
    }),
  },
  labelActive: {
    color:      T.violet500,
    fontWeight: '600',
    fontFamily: Platform.select({
      ios:     'Poppins',
      android: 'Poppins-SemiBold',
    }),
  },
  labelInactive: {
    color:      T.grey500,
    fontWeight: '400',
  },

  // ── [+] Button ─────────────────────────────────────────────────────────────
  plusWrapper: {
    flex:           1,
    alignItems:     'center',
    justifyContent: 'center',
    overflow:       'visible',
  },
  plusButton: {
    width:           T.PLUS_SIZE,
    height:          T.PLUS_SIZE,
    borderRadius:    T.PLUS_SIZE / 2,
    backgroundColor: T.violet500,
    alignItems:      'center',
    justifyContent:  'center',
    // protrude above tab bar (icon-system.md §6)
    marginTop:       T.PLUS_MT,
    // violet glow — --shadow-brand
    shadowColor:     T.shadowBrand,
    shadowOffset:    { width: 0, height: 8 },
    shadowOpacity:   0.25,
    shadowRadius:    16,
    elevation:       12,
  },
});

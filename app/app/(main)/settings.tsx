import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  TouchableOpacity,
} from 'react-native';
import {
  Heart,
  MapPin,
  Shield,
  FileText,
  MessageCircle,
  ChevronRight,
  Moon,
} from 'lucide-react-native';
import { Colors, Spacing, Typography } from '../../src/theme';
import { Card } from '../../src/components';
import { getChronotypeLabel, getGenderLabel } from '../../src/domain/models';
import { useUserStore } from '../../src/stores';
import type { JSX } from 'react';

export default function SettingsScreen(): JSX.Element {
  const profile = useUserStore((state) => state.profile);

  // Default values if profile is not loaded
  const nickname = profile?.nickname || 'ユーザー';
  const age = profile?.age || 30;
  const gender = profile?.gender || 'other';
  const chronotype = profile?.chronotype || 'intermediate';
  const targetBedtime = profile?.targetBedtime || '23:00';

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.title}>設定</Text>
        </View>

        {/* Profile Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>プロフィール</Text>
          <Card style={styles.profileCard}>
            <View style={styles.profileHeader}>
              <View style={styles.avatar}>
                <Text style={styles.avatarText}>{nickname.charAt(0)}</Text>
              </View>
              <View style={styles.profileInfo}>
                <Text style={styles.profileName}>{nickname}</Text>
                <Text style={styles.profileMeta}>
                  {age}歳 · {getGenderLabel(gender)}
                </Text>
              </View>
              <ChevronRight size={20} color={Colors.slate[400]} />
            </View>

            <View style={styles.profileDetails}>
              <ProfileRow
                icon={<Moon size={18} color={Colors.indigo[500]} />}
                label="クロノタイプ"
                value={getChronotypeLabel(chronotype)}
              />
              <ProfileRow
                icon={<Moon size={18} color={Colors.slate[500]} />}
                label="目標就寝時刻"
                value={targetBedtime}
              />
            </View>
          </Card>
        </View>

        {/* Data Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>データ</Text>
          <Card style={styles.menuCard}>
            <MenuItem
              icon={<Heart size={20} color={Colors.rose[500]} />}
              label="ヘルスケア連携"
              value="未確認"
              valueColor={Colors.primary[600]}
              onPress={() => {
                // TODO: Implement
              }}
            />
            <MenuItem
              icon={<MapPin size={20} color={Colors.blue[500]} />}
              label="位置情報"
              value="許可済み"
              valueColor={Colors.primary[600]}
              onPress={() => {
                // TODO: Implement
              }}
            />
          </Card>
        </View>

        {/* App Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>アプリについて</Text>
          <Card style={styles.menuCard}>
            <MenuItem
              icon={<Shield size={20} color={Colors.slate[500]} />}
              label="プライバシーポリシー"
              onPress={() => {
                // TODO: Implement
              }}
            />
            <MenuItem
              icon={<FileText size={20} color={Colors.slate[500]} />}
              label="利用規約"
              onPress={() => {
                // TODO: Implement
              }}
            />
            <MenuItem
              icon={<MessageCircle size={20} color={Colors.slate[500]} />}
              label="お問い合わせ"
              onPress={() => {
                // TODO: Implement
              }}
            />
          </Card>
        </View>

        {/* Version */}
        <View style={styles.versionContainer}>
          <Text style={styles.versionText}>TempoAI v1.0.0</Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const ProfileRow: React.FC<{
  icon: React.ReactNode;
  label: string;
  value: string;
}> = ({ icon, label, value }): JSX.Element => (
  <View style={styles.profileRow}>
    {icon}
    <Text style={styles.profileRowLabel}>{label}</Text>
    <Text style={styles.profileRowValue}>{value}</Text>
  </View>
);

const MenuItem: React.FC<{
  icon: React.ReactNode;
  label: string;
  value?: string;
  valueColor?: string;
  onPress: () => void;
}> = ({ icon, label, value, valueColor, onPress }): JSX.Element => (
  <TouchableOpacity style={styles.menuItem} onPress={onPress}>
    <View style={styles.menuItemLeft}>
      {icon}
      <Text style={styles.menuItemLabel}>{label}</Text>
    </View>
    <View style={styles.menuItemRight}>
      {value && (
        <Text style={[styles.menuItemValue, valueColor && { color: valueColor }]}>
          {value}
        </Text>
      )}
      <ChevronRight size={20} color={Colors.slate[300]} />
    </View>
  </TouchableOpacity>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.slate[50],
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: Spacing.lg,
    paddingTop: Spacing.lg,
    paddingBottom: Spacing.huge,
  },
  header: {
    marginBottom: Spacing.lg,
  },
  title: {
    ...Typography.h3,
    color: Colors.slate[800],
  },
  section: {
    marginBottom: Spacing.xl,
  },
  sectionTitle: {
    ...Typography.caption,
    color: Colors.slate[500],
    marginBottom: Spacing.sm,
    marginLeft: Spacing.xs,
    textTransform: 'uppercase',
    letterSpacing: 1,
  },
  profileCard: {
    padding: 0,
    overflow: 'hidden',
  },
  profileHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: Spacing.lg,
    borderBottomWidth: 1,
    borderBottomColor: Colors.slate[100],
  },
  avatar: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: Colors.primary[100],
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: Spacing.md,
  },
  avatarText: {
    ...Typography.h4,
    color: Colors.primary[600],
  },
  profileInfo: {
    flex: 1,
  },
  profileName: {
    ...Typography.h5,
    color: Colors.slate[800],
    marginBottom: 2,
  },
  profileMeta: {
    ...Typography.bodySmall,
    color: Colors.slate[500],
  },
  profileDetails: {
    padding: Spacing.lg,
    gap: Spacing.md,
  },
  profileRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  profileRowLabel: {
    ...Typography.bodySmall,
    color: Colors.slate[500],
    marginLeft: Spacing.sm,
    flex: 1,
  },
  profileRowValue: {
    ...Typography.bodySmall,
    color: Colors.slate[700],
    fontWeight: '500',
  },
  menuCard: {
    padding: 0,
    overflow: 'hidden',
  },
  menuItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: Spacing.lg,
    borderBottomWidth: 1,
    borderBottomColor: Colors.slate[50],
  },
  menuItemLeft: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  menuItemLabel: {
    ...Typography.body,
    color: Colors.slate[700],
    marginLeft: Spacing.md,
  },
  menuItemRight: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.sm,
  },
  menuItemValue: {
    ...Typography.bodySmall,
    color: Colors.slate[500],
  },
  versionContainer: {
    alignItems: 'center',
    paddingVertical: Spacing.xl,
  },
  versionText: {
    ...Typography.caption,
    color: Colors.slate[400],
  },
});

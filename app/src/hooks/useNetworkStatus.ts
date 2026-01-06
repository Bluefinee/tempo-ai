/**
 * ネットワーク状態を監視するフック
 */

import { useEffect, useState } from 'react';
import NetInfo, { NetInfoState } from '@react-native-community/netinfo';

/**
 * ネットワークステータス
 */
interface NetworkStatus {
  /** ネットワーク接続状態 */
  isConnected: boolean;
  /** インターネット到達可能性（nullの場合は不明） */
  isInternetReachable: boolean | null;
}

/**
 * ネットワーク状態を監視
 * @returns { isConnected, isInternetReachable }
 */
export const useNetworkStatus = (): NetworkStatus => {
  const [state, setState] = useState<NetInfoState | null>(null);

  useEffect(() => {
    // 初期状態を取得
    NetInfo.fetch().then(setState);

    // 状態変更を監視
    const unsubscribe = NetInfo.addEventListener(setState);
    return () => unsubscribe();
  }, []);

  return {
    isConnected: state?.isConnected ?? true,
    isInternetReachable: state?.isInternetReachable ?? null,
  };
};

/**
 * ネットワーク接続が利用可能かチェック（非フック版）
 * フックを使用できない場所でネットワーク状態を確認する場合に使用
 * @returns 接続されている場合はtrue、それ以外はfalse
 */
export const checkNetworkConnection = async (): Promise<boolean> => {
  const state = await NetInfo.fetch();
  return state.isConnected ?? false;
};


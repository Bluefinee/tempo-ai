/**
 * ネットワーク状態を監視するフック
 */

import { useEffect, useState } from 'react';
import NetInfo, { NetInfoState } from '@react-native-community/netinfo';

/** ネットワーク状態 */
interface NetworkStatus {
  /** インターネット接続があるか（不明時はfalse） */
  isConnected: boolean;
  /** インターネットに到達可能か（不明時はnull） */
  isInternetReachable: boolean | null;
}

/**
 * ネットワーク状態を監視するフック
 * @returns ネットワーク状態オブジェクト
 */
export const useNetworkStatus = (): NetworkStatus => {
  const [state, setState] = useState<NetInfoState | null>(null);

  useEffect(() => {
    NetInfo.fetch()
      .then(setState)
      .catch((error) => {
        console.error('Failed to fetch network state:', error);
        setState({
          isConnected: false,
          isInternetReachable: false,
        } as NetInfoState);
      });

    const unsubscribe = NetInfo.addEventListener(setState);
    return () => unsubscribe();
  }, []);

  return {
    isConnected: state?.isConnected ?? false,
    isInternetReachable: state?.isInternetReachable ?? null,
  };
};

/**
 * ネットワーク接続が利用可能かチェック（非フック版）
 * @returns 接続可能な場合true、エラー時はfalse
 */
export const checkNetworkConnection = async (): Promise<boolean> => {
  try {
    const state = await NetInfo.fetch();
    return state.isConnected ?? false;
  } catch (error) {
    console.error('Failed to check network connection:', error);
    return false;
  }
};


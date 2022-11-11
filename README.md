# ffmpeg-openh264-win

[BtbN/FFmpeg-Builds](https://github.com/BtbN/FFmpeg-Builds) のスクリプトを利用して Windows 用の FFmpeg を自動ビルドするリポジトリです。

毎月1回自動ビルドする設定にしてありますが、失敗などでスケジュールは変わるかも知れません。

## 特徴

- ビルドするのは Windows 32Bit / 64Bit、LGPL、shared のみ
- [OpenH264](https://github.com/cisco/openh264) が動的リンク（つまり使用時には openh264-x.y.z-win64.dll が別途必要）

import { Config } from "@remotion/cli/config";

Config.setVideoImageFormat("jpeg");
Config.setJpegQuality(95);
Config.setCodec("h264");
Config.setAudioCodec("aac");
Config.setAudioBitrate("192k");
Config.setCrf(18);
Config.setOverwriteOutput(true);

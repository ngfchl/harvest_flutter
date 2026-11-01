/// 常见 AI 服务提供商预设。
///
/// 用于配置页快速填充 provider / base_url / 默认模型。
/// 大部分第三方平台为 OpenAI 兼容网关，base_url 采用 `https://{domain}/v1` 约定，
/// 个别厂商使用各自专属路径；所有字段在表单中仍可手动修改。
class AiPresetService {
  final String name;
  final String provider;
  final String baseUrl;
  final String domain;
  final String category;
  final List<String> models;

  const AiPresetService({
    required this.name,
    required this.provider,
    required this.baseUrl,
    this.domain = '',
    required this.category,
    this.models = const [],
  });
}

const String kCatVendor = '模型厂商';
const String kCatThirdParty = '第三方平台';
const String kCatCloud = '云服务商';
const String kCatLocal = '本地';

const List<String> kAiPresetCategories = [kCatVendor, kCatThirdParty, kCatCloud, kCatLocal];

const List<AiPresetService> kAiPresetServices = [
  // ─────────────── 模型厂商 ───────────────
  AiPresetService(
    name: 'OpenAI',
    provider: 'openai',
    baseUrl: 'https://api.openai.com/v1',
    domain: 'api.openai.com',
    category: kCatVendor,
    models: ['gpt-4o-mini', 'gpt-4o', 'gpt-4.1-mini', 'gpt-4.1'],
  ),
  AiPresetService(
    name: 'DeepSeek',
    provider: 'openai',
    baseUrl: 'https://api.deepseek.com/v1',
    domain: 'platform.deepseek.com',
    category: kCatVendor,
    models: ['deepseek-chat', 'deepseek-reasoner'],
  ),
  AiPresetService(
    name: 'Kimi（月之暗面）',
    provider: 'openai',
    baseUrl: 'https://api.moonshot.cn/v1',
    domain: 'platform.kimi.com',
    category: kCatVendor,
    models: ['kimi-latest', 'moonshot-v1-8k', 'moonshot-v1-32k'],
  ),
  AiPresetService(
    name: '通义千问（阿里云百炼）',
    provider: 'openai',
    baseUrl: 'https://dashscope.aliyuncs.com/compatible-mode/v1',
    domain: 'platform.qianwanai.com',
    category: kCatVendor,
    models: ['qwen-plus', 'qwen-turbo', 'qwen-max', 'qwen3-max'],
  ),
  AiPresetService(
    name: '智谱 GLM',
    provider: 'openai',
    baseUrl: 'https://open.bigmodel.cn/api/paas/v4',
    domain: 'open.bigmodel.cn',
    category: kCatVendor,
    models: ['glm-4-flash', 'glm-4-air', 'glm-4-plus'],
  ),
  AiPresetService(
    name: 'MiniMax',
    provider: 'openai',
    baseUrl: 'https://api.minimax.chat/v1',
    domain: 'platform.minimax.cn',
    category: kCatVendor,
    models: ['MiniMax-Text-01', 'abab6.5s-chat'],
  ),
  AiPresetService(
    name: '火山引擎（豆包）',
    provider: 'openai',
    baseUrl: 'https://ark.cn-beijing.volces.com/api/v3',
    domain: 'volcengine.com',
    category: kCatVendor,
    models: ['doubao-pro-32k', 'doubao-lite-32k'],
  ),
  AiPresetService(
    name: '百度千帆',
    provider: 'openai',
    baseUrl: 'https://qianfan.baidubce.com/v2',
    domain: 'cloud.baidu.com',
    category: kCatVendor,
    models: ['ernie-4.0-turbo', 'ernie-3.5-8k'],
  ),
  AiPresetService(
    name: '腾讯云（混元）',
    provider: 'openai',
    baseUrl: 'https://api.lkeap.cloud.tencent.com/v1',
    domain: 'cloud.tencent.com',
    category: kCatVendor,
    models: ['hunyuan-turbos', 'hunyuan-large'],
  ),
  AiPresetService(
    name: '字节 BytePlus',
    provider: 'openai',
    baseUrl: 'https://ark.ap-southeast.bytepluses.com/api/v3',
    domain: 'byteplus.com',
    category: kCatVendor,
    models: ['skylark-pro-32k'],
  ),
  AiPresetService(
    name: 'StepFun（阶跃星辰）',
    provider: 'openai',
    baseUrl: 'https://api.stepfun.com/v1',
    domain: 'platform.stepfun.com',
    category: kCatVendor,
    models: ['step-1-8k', 'step-1-32k'],
  ),
  AiPresetService(
    name: 'Xiaomi MiMo',
    provider: 'openai',
    baseUrl: 'https://api.xiaomimimo.com/v1',
    domain: 'platform.xiaomimimo.com',
    category: kCatVendor,
    models: ['mimo-v2.6-flash', 'mimo-v2.6-pro'],
  ),
  AiPresetService(
    name: 'Xiaomi MiMo Token Plan',
    provider: 'openai',
    baseUrl: 'https://token-plan-cn.xiaomimimo.com/v1',
    domain: 'token-plan-cn.xiaomimimo.com',
    category: kCatVendor,
    models: ['mimo-v2.6-flash', 'mimo-v2.6-pro'],
  ),
  AiPresetService(
    name: 'Meta Model API',
    provider: 'openai',
    baseUrl: 'https://api.meta.ai/v1',
    domain: 'dev.meta.ai',
    category: kCatVendor,
  ),
  AiPresetService(
    name: 'BaiLing（百炼）',
    provider: 'openai',
    baseUrl: 'https://api.ant-ling.com/v1',
    domain: 'developer.ant-ling.com',
    category: kCatVendor,
  ),
  AiPresetService(
    name: 'Longcat（美团）',
    provider: 'openai',
    baseUrl: 'https://api.longcat.chat/v1',
    domain: 'longcat.chat',
    category: kCatVendor,
  ),
  AiPresetService(
    name: 'OwendCloud',
    provider: 'openai',
    baseUrl: 'https://api.owendcloud.com/v1',
    domain: 'home.owendcloud.com',
    category: kCatVendor,
  ),
  AiPresetService(
    name: 'StreamLake（快手）',
    provider: 'openai',
    baseUrl: 'https://api.streamlake.com/v1',
    domain: 'streamlake.com',
    category: kCatVendor,
  ),
  AiPresetService(
    name: 'iShot',
    provider: 'openai',
    baseUrl: 'https://api.xyfun.cn/v1',
    domain: 'maas.xyfun.cn',
    category: kCatVendor,
  ),

  // ─────────────── 第三方平台 ───────────────
  AiPresetService(name: '88API', provider: 'openai', baseUrl: 'https://api.88api.ai/v1', domain: '88api.ai', category: kCatThirdParty),
  AiPresetService(name: '9527CODE', provider: 'openai', baseUrl: 'https://api.9527.codes/v1', domain: '9527.codes', category: kCatThirdParty),
  AiPresetService(name: 'A6API', provider: 'openai', baseUrl: 'https://api.a6api.com/v1', domain: 'a6api.com', category: kCatThirdParty),
  AiPresetService(name: 'AICodeMirror', provider: 'openai', baseUrl: 'https://api.aicodemirror.ai/v1', domain: 'aicodemirror.ai', category: kCatThirdParty),
  AiPresetService(name: 'AiCodeWith', provider: 'openai', baseUrl: 'https://api.aicodewith.ai/v1', domain: 'aicodewith.ai', category: kCatThirdParty),
  AiPresetService(name: 'AiCoding', provider: 'openai', baseUrl: 'https://api.aicoding.icu/v1', domain: 'aicoding.icu', category: kCatThirdParty),
  AiPresetService(name: 'AIComing', provider: 'openai', baseUrl: 'https://api.aicoming.top/v1', domain: 'aicoming.top', category: kCatThirdParty),
  AiPresetService(name: 'AiGoCode', provider: 'openai', baseUrl: 'https://api.aigocode.net/v1', domain: 'aigocode.net', category: kCatThirdParty),
  AiPresetService(name: 'AiHubMix', provider: 'openai', baseUrl: 'https://api.aihubmix.com/v1', domain: 'aihubmix.com', category: kCatThirdParty),
  AiPresetService(name: 'AllTokens', provider: 'openai', baseUrl: 'https://api.alltokens.cc/v1', domain: 'alltokens.cc', category: kCatThirdParty),
  AiPresetService(name: 'Amux', provider: 'openai', baseUrl: 'https://api.amux.ai/v1', domain: 'amux.ai', category: kCatThirdParty),
  AiPresetService(name: 'APIKEY.FUN', provider: 'openai', baseUrl: 'https://api.apikey.fun/v1', domain: 'apikey.fun', category: kCatThirdParty),
  AiPresetService(name: 'APINebula', provider: 'openai', baseUrl: 'https://api.apinebula.ai/v1', domain: 'apinebula.ai', category: kCatThirdParty),
  AiPresetService(name: 'AtlasCloud', provider: 'openai', baseUrl: 'https://api.atlascloud.ai/v1', domain: 'atlascloud.ai', category: kCatThirdParty),
  AiPresetService(name: 'Azure OpenAI', provider: 'openai', baseUrl: 'https://YOUR-RESOURCE.openai.azure.com/openai/v1', domain: 'learn.microsoft.com', category: kCatThirdParty),
  AiPresetService(name: 'Baseten', provider: 'openai', baseUrl: 'https://api.baseten.co/v1', domain: 'baseten.co', category: kCatThirdParty),
  AiPresetService(name: 'BotCF', provider: 'openai', baseUrl: 'https://api.botcf.com/v1', domain: 'botcf.com', category: kCatThirdParty),
  AiPresetService(name: '调元工厂', provider: 'openai', baseUrl: 'https://api.tokenfactory.cn/v1', domain: 'tokenfactory.cn', category: kCatThirdParty),
  AiPresetService(name: 'CCSub', provider: 'openai', baseUrl: 'https://api.ccsub.net/v1', domain: 'ccsub.net', category: kCatThirdParty),
  AiPresetService(name: 'CherryIN', provider: 'openai', baseUrl: 'https://open.cherryin.ai/v1', domain: 'open.cherryin.ai', category: kCatThirdParty),
  AiPresetService(name: 'ClaudeCN', provider: 'openai', baseUrl: 'https://api.claudecn.top/v1', domain: 'claudecn.top', category: kCatThirdParty),
  AiPresetService(name: 'Code0', provider: 'openai', baseUrl: 'https://api.code0.ai/v1', domain: 'code0.ai', category: kCatThirdParty),
  AiPresetService(name: 'Command Code', provider: 'openai', baseUrl: 'https://api.commandcode.ai/v1', domain: 'commandcode.ai', category: kCatThirdParty),
  AiPresetService(name: 'CrazyRouter', provider: 'openai', baseUrl: 'https://api.crazyrouter.com/v1', domain: 'crazyrouter.com', category: kCatThirdParty),
  AiPresetService(name: 'Cubence', provider: 'openai', baseUrl: 'https://api.cubence.com/v1', domain: 'cubence.com', category: kCatThirdParty),
  AiPresetService(name: 'DeepInfra', provider: 'openai', baseUrl: 'https://api.deepinfra.com/v1/openai', domain: 'deepinfra.com', category: kCatThirdParty),
  AiPresetService(name: 'DMXAPI', provider: 'openai', baseUrl: 'https://www.dmxapi.cn/v1', domain: 'dmxapi.cn', category: kCatThirdParty),
  AiPresetService(name: 'E-FlowCode', provider: 'openai', baseUrl: 'https://api.e-flowcode.cc/v1', domain: 'e-flowcode.cc', category: kCatThirdParty),
  AiPresetService(name: 'EveryAPI', provider: 'openai', baseUrl: 'https://api.everyapi.ai/v1', domain: 'everyapi.ai', category: kCatThirdParty),
  AiPresetService(name: 'FennoAI', provider: 'openai', baseUrl: 'https://api.fenno.ai/v1', domain: 'api.fenno.ai', category: kCatThirdParty),
  AiPresetService(name: 'FluxA Token Plan', provider: 'openai', baseUrl: 'https://api.fluxapay.xyz/v1', domain: 'agentmarket.fluxapay.xyz', category: kCatThirdParty),
  AiPresetService(name: 'GrooRoute Pro', provider: 'openai', baseUrl: 'https://api.grooroute.pro/v1', domain: 'grooroute.pro', category: kCatThirdParty),
  AiPresetService(
    name: 'Groq',
    provider: 'openai',
    baseUrl: 'https://api.groq.com/openai/v1',
    domain: 'groq.com',
    category: kCatThirdParty,
    models: ['llama-3.3-70b-versatile', 'llama-3.1-8b-instant'],
  ),
  AiPresetService(name: 'Hugging Face', provider: 'openai', baseUrl: 'https://router.huggingface.co/v1', domain: 'huggingface.co', category: kCatThirdParty),
  AiPresetService(name: 'IKunCode', provider: 'openai', baseUrl: 'https://api.ikuncode.ai/v1', domain: 'api.ikuncode.ai', category: kCatThirdParty),
  AiPresetService(name: 'JieKou AI', provider: 'openai', baseUrl: 'https://api.jiekou.ai/v1', domain: 'jiekou.ai', category: kCatThirdParty),
  AiPresetService(name: '模力方舟', provider: 'openai', baseUrl: 'https://api.msark.com/v1', domain: 'msark.com', category: kCatThirdParty),
  AiPresetService(name: 'Micu', provider: 'openai', baseUrl: 'https://api.micuapi.ai/v1', domain: 'micuapi.ai', category: kCatThirdParty),
  AiPresetService(name: 'Modelflare', provider: 'openai', baseUrl: 'https://api.modelflare.dev/v1', domain: 'modelflare.dev', category: kCatThirdParty),
  AiPresetService(name: 'ModelScope（魔搭）', provider: 'openai', baseUrl: 'https://api-inference.modelscope.cn/v1', domain: 'modelscope.cn', category: kCatThirdParty),
  AiPresetService(name: 'Neblus Token Factory', provider: 'openai', baseUrl: 'https://api.nebius.com/v1', domain: 'nebius.com', category: kCatThirdParty),
  AiPresetService(name: 'NekoCode', provider: 'openai', baseUrl: 'https://api.nekoapi.ai/v1', domain: 'nekoapi.ai', category: kCatThirdParty),
  AiPresetService(name: 'Novita AI', provider: 'openai', baseUrl: 'https://api.novita.ai/v3/openai', domain: 'novita.ai', category: kCatThirdParty),
  AiPresetService(name: 'Nvidia', provider: 'openai', baseUrl: 'https://integrate.api.nvidia.com/v1', domain: 'build.nvidia.com', category: kCatThirdParty),
  AiPresetService(name: 'OpenCode', provider: 'openai', baseUrl: 'https://api.opencode.ai/v1', domain: 'opencode.ai', category: kCatThirdParty),
  AiPresetService(name: 'OpenModel', provider: 'openai', baseUrl: 'https://api.openmodel.ai/v1', domain: 'openmodel.ai', category: kCatThirdParty),
  AiPresetService(
    name: 'OpenRouter',
    provider: 'openai',
    baseUrl: 'https://openrouter.ai/api/v1',
    domain: 'openrouter.ai',
    category: kCatThirdParty,
    models: ['openai/gpt-4o-mini', 'google/gemini-2.0-flash-001'],
  ),
  AiPresetService(name: 'PackyCode', provider: 'openai', baseUrl: 'https://api.packyapi.ai/v1', domain: 'packyapi.ai', category: kCatThirdParty),
  AiPresetService(name: 'PatewayAI', provider: 'openai', baseUrl: 'https://api.pateway.ai/v1', domain: 'pateway.ai', category: kCatThirdParty),
  AiPresetService(name: 'PIPELLM', provider: 'openai', baseUrl: 'https://code.pipellm.ai/v1', domain: 'code.pipellm.ai', category: kCatThirdParty),
  AiPresetService(name: 'PPIO（派欧云）', provider: 'openai', baseUrl: 'https://api.ppinfra.com/v3/openai', domain: 'ppio.com', category: kCatThirdParty),
  AiPresetService(name: '七牛云', provider: 'openai', baseUrl: 'https://api.qiniu.com/v1', domain: 's.qiniu.com', category: kCatThirdParty),
  AiPresetService(name: 'RelaxyCode', provider: 'openai', baseUrl: 'https://api.relaxycode.com/v1', domain: 'relaxycode.com', category: kCatThirdParty),
  AiPresetService(name: 'RightCode', provider: 'openai', baseUrl: 'https://api.rightapi.ai/v1', domain: 'rightapi.ai', category: kCatThirdParty),
  AiPresetService(name: 'RunAPI', provider: 'openai', baseUrl: 'https://api.runapi.host/v1', domain: 'runapi.host', category: kCatThirdParty),
  AiPresetService(name: 'RunToken', provider: 'openai', baseUrl: 'https://api.runtoken.ai/v1', domain: 'runtoken.ai', category: kCatThirdParty),
  AiPresetService(name: '胜算云', provider: 'openai', baseUrl: 'https://api.shengsuanyun.com/v1', domain: 'shengsuanyun.com', category: kCatThirdParty),
  AiPresetService(
    name: 'SiliconFlow（硅基流动）',
    provider: 'openai',
    baseUrl: 'https://api.siliconflow.cn/v1',
    domain: 'siliconflow.cn',
    category: kCatThirdParty,
    models: ['Qwen/Qwen2.5-7B-Instruct', 'deepseek-ai/DeepSeek-V3'],
  ),
  AiPresetService(name: 'SoleAPI', provider: 'openai', baseUrl: 'https://api.soleapi.com/v1', domain: 'soleapi.com', category: kCatThirdParty),
  AiPresetService(name: 'SoruxGPT', provider: 'openai', baseUrl: 'https://ai.soruxgpt.com/v1', domain: 'ai.soruxgpt.com', category: kCatThirdParty),
  AiPresetService(name: 'Soshow', provider: 'openai', baseUrl: 'https://aimarket.so-show.com/v1', domain: 'aimarket.so-show.com', category: kCatThirdParty),
  AiPresetService(name: 'SSSAICode', provider: 'openai', baseUrl: 'https://api.sssaicodeapi.com/v1', domain: 'sssaicodeapi.com', category: kCatThirdParty),
  AiPresetService(name: 'SubRouter', provider: 'openai', baseUrl: 'https://api.subrouter.ai/v1', domain: 'subrouter.ai', category: kCatThirdParty),
  AiPresetService(name: 'SudoCode', provider: 'openai', baseUrl: 'https://api.sudocode.chat/v1', domain: 'sudocode.chat', category: kCatThirdParty),
  AiPresetService(name: '兔子 API', provider: 'openai', baseUrl: 'https://api.tu-zi.com/v1', domain: 'api.tu-zi.com', category: kCatThirdParty),
  AiPresetService(name: 'TeamoRouter', provider: 'openai', baseUrl: 'https://api.teamorouter.cn/v1', domain: 'teamorouter.cn', category: kCatThirdParty),
  AiPresetService(name: 'TheRouter', provider: 'openai', baseUrl: 'https://api.therouter.ai/v1', domain: 'therouter.ai', category: kCatThirdParty),
  AiPresetService(name: 'TokenFlux', provider: 'openai', baseUrl: 'https://api.tokenflux.dev/v1', domain: 'tokenflux.dev', category: kCatThirdParty),
  AiPresetService(name: 'Vercel AI Gateway', provider: 'openai', baseUrl: 'https://ai-gateway.vercel.sh/v1', domain: 'vercel.com', category: kCatThirdParty),
  AiPresetService(name: 'xAI（Grok）', provider: 'openai', baseUrl: 'https://api.x.ai/v1', domain: 'x.ai', category: kCatThirdParty),
  AiPresetService(name: 'XycAi', provider: 'openai', baseUrl: 'https://api.xycal.us/v1', domain: 'xycal.us', category: kCatThirdParty),
  AiPresetService(name: '优云智算', provider: 'openai', baseUrl: 'https://api.compshare.cn/v1', domain: 'compshare.cn', category: kCatThirdParty),
  AiPresetService(name: '鱼目混珠', provider: 'openai', baseUrl: 'https://api.yyks.io/v1', domain: 'yyks.io', category: kCatThirdParty),
  AiPresetService(name: 'ZetaAPI', provider: 'openai', baseUrl: 'https://api.zetaapi.ai/v1', domain: 'zetaapi.ai', category: kCatThirdParty),

  // ─────────────── 云服务商 ───────────────
  AiPresetService(name: 'Cloudflare AI Gateway', provider: 'openai', baseUrl: 'https://api.cloudflare.com/client/v4/accounts/YOUR_ACCOUNT/ai/v1', domain: 'developers.cloudflare.com', category: kCatCloud),
  AiPresetService(name: 'DigitalOcean', provider: 'openai', baseUrl: 'https://api.digitalocean.com/v1', domain: 'digitalocean.com', category: kCatCloud),
  AiPresetService(name: 'Fireworks AI', provider: 'openai', baseUrl: 'https://api.fireworks.ai/inference/v1', domain: 'fireworks.ai', category: kCatCloud),
  AiPresetService(name: 'Ollama Cloud', provider: 'openai', baseUrl: 'https://ollama.com/v1', domain: 'ollama.com', category: kCatCloud),
  AiPresetService(name: 'SambaNova', provider: 'openai', baseUrl: 'https://api.sambanova.ai/v1', domain: 'sambanova.ai', category: kCatCloud),

  // ─────────────── 本地 ───────────────
  AiPresetService(
    name: 'Ollama 本地',
    provider: 'ollama',
    baseUrl: 'http://localhost:11434',
    domain: 'localhost:11434',
    category: kCatLocal,
    models: ['llama3.2', 'qwen2.5', 'mistral'],
  ),
  AiPresetService(name: 'LM Studio', provider: 'openai', baseUrl: 'http://localhost:1234/v1', domain: 'localhost:1234', category: kCatLocal),
  AiPresetService(name: 'llama.cpp', provider: 'openai', baseUrl: 'http://localhost:8080/v1', domain: 'localhost:8080', category: kCatLocal),

  // ─────────────── 兜底 ───────────────
  AiPresetService(name: '自定义地址', provider: 'openai', baseUrl: '', domain: '', category: kCatLocal),
];

/// 按 baseUrl 反查预设，用于回显已选预设。
AiPresetService? findAiPresetByBaseUrl(String baseUrl) {
  final target = baseUrl.trim();
  if (target.isEmpty) return null;
  for (final preset in kAiPresetServices) {
    if (preset.baseUrl.isEmpty) continue;
    if (target == preset.baseUrl || target.startsWith(preset.baseUrl)) return preset;
  }
  return null;
}

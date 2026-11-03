#!/usr/bin/env node
/* Offline gate for the public demonstration build. Scans restored text sources or
   every entry of an APK after decompression. It deliberately rejects credentials,
   contact data, genuine IP literals and configured numeric PINs. */
const fs=require('fs'),path=require('path'),os=require('os'),cp=require('child_process');
const root=path.resolve(__dirname,'..');
const isApk=process.argv[2]==='--apk';
const target=isApk?path.resolve(process.argv[3]||''):root;
if(isApk&&(!target||!fs.existsSync(target))) throw new Error('Informe um APK existente após --apk.');
const work=isApk?fs.mkdtempSync(path.join(os.tmpdir(),'aspas-apk-scan-')):root;
if(isApk) cp.execFileSync('unzip',['-qq',target,'-d',work],{stdio:'inherit'});
const roots=isApk?[work]:['app','tests','tools','docs','README.md','PUBLICACAO.json','PROMPT-EMERGENT.md'].map(x=>path.join(root,x));
const findings=[];
const rules=[
 ['e-mail',/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/ig],
 ['telefone brasileiro',/(?:\+?55\s*)?(?:\(\d{2}\)|\d{2}[-\s])\s*(?:9\s?)?\d{4}[-\s]\d{4}\b/g],
 ['CPF',/\b\d{3}[.\s]?\d{3}[.\s]?\d{3}[-\s]?\d{2}\b/g],
 ['IP público/privado literal',/\b(?!(?:192\.0\.2|198\.51\.100|203\.0\.113)\.)(?!(?:0|127|255)\.)(?:\d{1,3}\.){3}\d{1,3}\b/g],
 ['token/chave',/\b(?:gh[pousr]_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,}|AIza[0-9A-Za-z_-]{20,}|AKIA[0-9A-Z]{16}|sk_(?:live|test)_[A-Za-z0-9]{16,}|-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----)\b/g],
 ['PIN literal configurado',/"(?:pin|pinHash|password|senha)"\s*:\s*"(?:\d{4,}|(?!pbkdf2)[^"]{8,})"/ig]
];
function files(p){if(!fs.existsSync(p))return[];const s=fs.statSync(p);if(s.isFile())return[p];let a=[];for(const e of fs.readdirSync(p,{withFileTypes:true})){if(['.git','.gradle','build','node_modules'].includes(e.name))continue;a=a.concat(files(path.join(p,e.name)))}return a}
for(const f of roots.flatMap(files)){let b=fs.readFileSync(f);let text=b.toString('utf8');if(text.includes('\uFFFD')) text=b.toString('latin1');for(const [kind,re] of rules){for(const m of text.matchAll(re)){findings.push({file:path.relative(work,f)||path.basename(f),kind,value:m[0].slice(0,160)});if(findings.length>=100)break}if(findings.length>=100)break}if(findings.length>=100)break}
const scannedFiles=roots.flatMap(files).length;
if(isApk)fs.rmSync(work,{recursive:true,force:true});
if(findings.length){console.error(JSON.stringify({result:'BLOCKED',findings},null,2));process.exit(2)}
console.log(JSON.stringify({result:'PASS',scope:isApk?'APK descompactado':'fontes restaurados',files:scannedFiles,rules:rules.map(r=>r[0])},null,2));

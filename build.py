import os,pathlib,subprocess,zipfile,hashlib,json,traceback
root=pathlib.Path(__file__).resolve().parent
sdk=pathlib.Path(os.environ['LOCALAPPDATA'])/'Android'/'Sdk'
bt=sdk/'build-tools'/'36.0.0'
java=pathlib.Path(r'C:\Program Files\Eclipse Adoptium\jdk-21.0.12.101-hotspot\bin')
android=sdk/'platforms'/'android-36'/'android.jar'
def run(*args):
 p=subprocess.run([str(a) for a in args],cwd=root,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,encoding='utf-8',errors='replace')
 print(p.stdout,flush=True)
 if p.returncode:raise RuntimeError('Build step failed: '+str(args[0]))
try:
 for name in ['build','build/gen','build/classes','build/dex','output']: (root/name).mkdir(exist_ok=True)
 run(bt/'aapt2.exe','compile','--dir','res','-o','build/compiled.zip')
 run(bt/'aapt2.exe','link','-o','build/resources.apk','-I',android,'--manifest','AndroidManifest.xml','--java','build/gen','-A','assets','build/compiled.zip')
 sources=list((root/'src').rglob('*.java'))+list((root/'build/gen').rglob('*.java'))
 run(java/'javac.exe','-encoding','UTF-8','-source','8','-target','8','-classpath',android,'-d','build/classes',*sources)
 run(java/'java.exe','-cp',bt/'lib'/'d8.jar','com.android.tools.r8.D8','--lib',android,'--min-api','26','--output','build/dex',*list((root/'build/classes').rglob('*.class')))
 import shutil
 shutil.copyfile(root/'build/resources.apk',root/'build/unsigned.apk')
 with zipfile.ZipFile(root/'build/unsigned.apk','a',compression=zipfile.ZIP_DEFLATED) as z:
  for d in (root/'build/dex').glob('*.dex'):z.write(d,d.name)
 run(bt/'zipalign.exe','-f','-p','4','build/unsigned.apk','build/aligned.apk')
 # Dedicated Android test key, never used for the production release.
 key=root/'rinat-preview.keystore'
 if not key.exists():run(java/'keytool.exe','-genkeypair','-keystore',key,'-storepass','android','-keypass','android','-alias','androiddebugkey','-keyalg','RSA','-keysize','2048','-validity','3650','-dname','CN=Rinat Abu Preview,O=Development,C=IL')
 out=root/'output'/'RINAT-ABU-0.3.1-preview.apk'
 run(java/'java.exe','-jar',bt/'lib'/'apksigner.jar','sign','--ks',key,'--ks-pass','pass:android','--key-pass','pass:android','--out',out,'build/aligned.apk')
 run(java/'java.exe','-jar',bt/'lib'/'apksigner.jar','verify','--verbose',out)
 run(bt/'aapt2.exe','dump','badging',out)
 report={'status':'success','apk':str(out),'bytes':out.stat().st_size,'sha256':hashlib.sha256(out.read_bytes()).hexdigest(),'device_tested':False,'signing':'dedicated preview key'}
 (root/'build-result.json').write_text(json.dumps(report),encoding='utf-8');print(json.dumps(report),flush=True)
except Exception:
 (root/'build-result.json').write_text(json.dumps({'status':'failed','error':traceback.format_exc()}),encoding='utf-8');raise

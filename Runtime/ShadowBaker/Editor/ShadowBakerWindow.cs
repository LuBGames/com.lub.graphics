using System.Linq;
using System.Threading.Tasks;
using UnityEditor;
using UnityEditor.UIElements;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.UIElements;
using Object = UnityEngine.Object;

namespace LuBGraphics.ShadowBaker
{
    public class ShadowBakerWindow : EditorWindow
    {
        private RenderTexture _shadowMapRender;
        private RenderTexture _shadowMapResult;
        private RenderTexture _shadowMap;
        private Light _lightSource;

        private Material _pcfShadows;

        private CommandBuffer _renderShadows;
        
        private Material _shadowBakerMaterial;

        private GameObject _obj;

        private Image _prevImage;

        [MenuItem("LuB/ShadowBaker")]
        public static void ShowWindow()
        {
            ShadowBakerWindow window = GetWindow<ShadowBakerWindow>();
            window.titleContent = new GUIContent("Shadow Baker");
        }

        private void CreateGUI()
        {
            VisualElement root = rootVisualElement;

            _lightSource = RenderSettings.sun;

            ObjectField objectField = new ObjectField("Object");
            objectField.RegisterCallback<ChangeEvent<Object>>(OnChangeObject);
            root.Add(objectField);

            Button button = new Button(Bake)
            {
                text = "Bake"
            };
            root.Add(button);
            
            _prevImage = new Image();
            root.Add(_prevImage);
            
            Button saveButton = new Button(Save)
            {
                text = "Save"
            };
            root.Add(saveButton);
        }

        private void OnChangeObject(ChangeEvent<Object> evt)
        {
            _obj = evt.newValue as GameObject;
        }

        private Renderer[] _renderers;
        private ShadowCastingMode[] _shadowCastingModes;

        private void Bake()
        {
            if (_obj == null) return;

            _renderers = FindObjectsOfType<Renderer>();
            _shadowCastingModes = _renderers.Select(r => r.shadowCastingMode).ToArray();

            foreach (var r in _renderers)
            {
                if (!r.gameObject.isStatic)
                {
                    r.shadowCastingMode = ShadowCastingMode.Off;
                }
            }
            
            if (_shadowBakerMaterial == null)
                _shadowBakerMaterial = new Material(Shader.Find("Hidden/ShadowBaker"));
            
            if (_shadowMapRender == null)
            {
                _shadowMapRender = new RenderTexture(1024, 1024, 0)
                {
                    enableRandomWrite = true,
                    depthStencilFormat = GraphicsFormat.D24_UNorm
                };
                _shadowMapRender.Create();
            }
            
            if (_shadowMapResult == null)
            {
                _shadowMapResult = new RenderTexture(1024, 1024, 0)
                {
                    enableRandomWrite = true,
                    depthStencilFormat = GraphicsFormat.D24_UNorm
                };
                _shadowMapResult.Create();
            }

            if (_shadowMap == null)
            {
                _shadowMap = new RenderTexture(1024, 1024, 0, RenderTextureFormat.R16)
                {
                    enableRandomWrite = true
                };

                _shadowMap.Create();
            }

            if (_pcfShadows == null)
            {
                _pcfShadows = new Material(Shader.Find("Hidden/PCFShadow"));
            }

            if (_renderShadows == null)
            {
                _renderShadows = new CommandBuffer() {name = "Render Shadows"};

                _renderShadows.CopyTexture(BuiltinRenderTextureType.CurrentActive, _shadowMap);

                _lightSource.AddCommandBuffer(LightEvent.AfterShadowMap, _renderShadows);
            }
            else
            {
                _lightSource.AddCommandBuffer(LightEvent.AfterShadowMap, _renderShadows);
            }

            _lightSource.SetLightDirty();
            
            Wait();
        }

        private async void Wait()
        {
            await Task.Yield();
            await Task.Yield();
            await Task.Yield();

            for (int i = 0; i < _renderers.Length; i++)
            {
                var r = _renderers[i];
                if (!r.gameObject.isStatic)
                {
                    r.shadowCastingMode = _shadowCastingModes[i];
                }
            }

            Mesh mesh = _obj.GetComponent<MeshFilter>().sharedMesh;
            
            _shadowBakerMaterial.SetKeyword(new LocalKeyword(Shader.Find("Hidden/ShadowBaker"), "SHADOWS_SCREEN"), true);
            _shadowBakerMaterial.SetTexture("_Shadows", _shadowMap);
            
            Graphics.SetRenderTarget(_shadowMapRender);
            _shadowBakerMaterial.SetPass(0);
            Graphics.DrawMeshNow(mesh, _obj.transform.localToWorldMatrix);
            
            _lightSource.RemoveCommandBuffers(LightEvent.AfterShadowMap);
            
            _pcfShadows.SetTexture("_MainTex", _shadowMapRender);
            _pcfShadows.SetVector("_Size", new Vector2(1f/_shadowMapRender.width, 1f/_shadowMapRender.height));

            Graphics.Blit(null, _shadowMapResult, _pcfShadows);

            _prevImage.image = _shadowMapResult;
        }
        
        private void Save()
        {
            Texture2D tex = ToTexture2D(_shadowMapResult);
            byte[] pngBytes = tex.EncodeToPNG();
            string path = "Assets/shadowBake.png";
            System.IO.File.WriteAllBytes(path, pngBytes);
            AssetDatabase.ImportAsset(path);
            DestroyImmediate(tex);
        }

        private void OnDestroy()
        {
            DestroyImmediate(_shadowMap);
            DestroyImmediate(_shadowMapRender);
            DestroyImmediate(_shadowMapResult);
        }

        static Texture2D ToTexture2D(RenderTexture rTex)
        {
            Texture2D tex = new Texture2D(rTex.width, rTex.height, TextureFormat.RGB24, false);
            // ReadPixels looks at the active RenderTexture.
            RenderTexture.active = rTex;
            tex.ReadPixels(new Rect(0, 0, rTex.width, rTex.height), 0, 0);
            tex.Apply();
            return tex;
        }
    }
}
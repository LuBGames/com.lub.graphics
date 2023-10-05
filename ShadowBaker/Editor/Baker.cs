using System.Threading.Tasks;
using UnityEditor;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;

namespace LuBGraphics.ShadowBaker.Editor
{
    [ExecuteAlways]
    public class Baker : MonoBehaviour
    {
        [SerializeField] private RenderTexture shadowMapRender;
        [SerializeField] private RenderTexture shadowMapResult;
        [SerializeField] private RenderTexture shadowMap;
        [SerializeField] private Light direct;

        private Material _pcfShadows;

        private CommandBuffer _renderShadows;
        
        private Material _shadowBakerMaterial;

        private Mesh _mesh;

        private bool _dirt;

        [ContextMenu("Bake")]
        private void Bake()
        {
            if (_shadowBakerMaterial == null)
                _shadowBakerMaterial = new Material(Shader.Find("Hidden/ShadowBaker"));
            
            if (shadowMapRender == null)
            {
                shadowMapRender = new RenderTexture(1024, 1024, 0)
                {
                    enableRandomWrite = true,
                    depthStencilFormat = GraphicsFormat.D24_UNorm
                };
                shadowMapRender.Create();
            }
            
            if (shadowMapResult == null)
            {
                shadowMapResult = new RenderTexture(1024, 1024, 0)
                {
                    enableRandomWrite = true,
                    depthStencilFormat = GraphicsFormat.D24_UNorm
                };
                shadowMapResult.Create();
            }

            if (shadowMap == null)
            {
                shadowMap = new RenderTexture(1024, 1024, 0, RenderTextureFormat.R16)
                {
                    enableRandomWrite = true
                };

                shadowMap.Create();
            }

            if (_pcfShadows == null)
            {
                _pcfShadows = new Material(Shader.Find("Hidden/PCFShadow"));
            }

            if (_renderShadows == null)
            {
                _renderShadows = new CommandBuffer() {name = "Render Shadows"};

                _renderShadows.CopyTexture(BuiltinRenderTextureType.CurrentActive, shadowMap);
                
                direct.AddCommandBuffer(LightEvent.AfterShadowMap, _renderShadows);
            }
            else
            {
                direct.AddCommandBuffer(LightEvent.AfterShadowMap, _renderShadows);
            }
            
            Wait();
        }

        private async void Wait()
        {
            await Task.Yield();

            Mesh mesh = GetComponent<MeshFilter>().sharedMesh;
            
            _shadowBakerMaterial.SetKeyword(new LocalKeyword(Shader.Find("Hidden/ShadowBaker"), "SHADOWS_SCREEN"), true);
            _shadowBakerMaterial.SetTexture("_Shadows", shadowMap);
            
            Graphics.SetRenderTarget(shadowMapRender);
            _shadowBakerMaterial.SetPass(0);
            Graphics.DrawMeshNow(mesh, transform.localToWorldMatrix);
            
            direct.RemoveCommandBuffers(LightEvent.AfterShadowMap);
            
            _pcfShadows.SetTexture("_MainTex", shadowMapRender);
            _pcfShadows.SetVector("_Size", new Vector2(1f/shadowMapRender.width, 1f/shadowMapRender.height));

            Graphics.Blit(null, shadowMapResult, _pcfShadows);
        }

        [ContextMenu("Save")]
        private void Save()
        {
            Texture2D tex = toTexture2D(shadowMapResult);
            byte[] pngBytes = tex.EncodeToPNG();
            string path = "Assets/shadowBake.png";
            System.IO.File.WriteAllBytes(path, pngBytes);
            AssetDatabase.ImportAsset(path);
            
            Destroy(tex);
            Destroy(shadowMap);
            Destroy(shadowMapRender);
            Destroy(shadowMapResult);
        }
        
        Texture2D toTexture2D(RenderTexture rTex)
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
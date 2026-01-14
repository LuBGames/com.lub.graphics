using UnityEngine;
using UnityEngine.Rendering;

namespace LuB.Graphics
{
    [ExecuteAlways]
    public class SkyboxSettings : MonoBehaviour
    {
        [SerializeField] private Texture skyboxTexture;
        
        [ColorUsage(false)] public Color TopCollor;
        [ColorUsage(false)] public Color BottomCollor;
        public float Exponent;

        private GlobalKeyword _gradientKeyword;

        private void OnValidate()
        {
            UpdateState();
        }

        private void OnEnable()
        {
            UpdateState();
        }

        private void LateUpdate()
        {
            UpdateState();
        }

        private void UpdateState()
        {
            if (string.IsNullOrEmpty(_gradientKeyword.name))
            {
                _gradientKeyword = GlobalKeyword.Create("GRADIENT_SKYBOX");
            }
            if (skyboxTexture == null)
            {
                Shader.SetKeyword(_gradientKeyword, true);
                Shader.SetGlobalColor("TopColorSkybox", TopCollor);
                Shader.SetGlobalColor("BottomColorSkybox", BottomCollor);
                Shader.SetGlobalVector("UpSkybox", transform.up);
                Shader.SetGlobalFloat("ExpSkybox", Exponent);
            }
            else
            {
                Shader.SetKeyword(_gradientKeyword, false);
                Shader.SetGlobalTexture("_Skybox", skyboxTexture);
            }
        }
    }
}
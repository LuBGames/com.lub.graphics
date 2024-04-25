using UnityEngine;
using UnityEngine.Rendering;

namespace LuB.Graphics
{
    public class LubGraphicsSettings : MonoBehaviour
    {
        public bool UseShadowColorForShading;
        public bool UseExpensiveShading;
        
        private void OnValidate()
        {
            UpdateSettings();
        }

        private void Awake()
        {
            UpdateSettings();
        }

        private void UpdateSettings()
        {
            Shader.SetKeyword(GlobalKeyword.Create("USE_SHADOW_COLOR_FOR_SHADING"), UseShadowColorForShading);
            Shader.SetKeyword(GlobalKeyword.Create("USE_SHADE_SH9"), UseExpensiveShading);
        }
    }
}
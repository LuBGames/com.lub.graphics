using UnityEngine;
using UnityEngine.Rendering;

namespace LuB.Graphics
{
    public class FogController : MonoBehaviour
    {
        public Vector3 FogOffset;
        public Vector3 FogAxis;
        public float FogScale;

        public bool UseShadowColorForShading;

        private void OnValidate()
        {
            UpdateState();
            Shader.SetKeyword(GlobalKeyword.Create("USE_SHADOW_COLOR_FOR_SHADING"), UseShadowColorForShading);
        }

        private void LateUpdate()
        {
            UpdateState();
        }

        private void UpdateState()
        {
            Shader.SetGlobalVector("FogOffset", FogOffset);
            Shader.SetGlobalVector("FogAxis", FogAxis);
            Shader.SetGlobalFloat("FogScale", FogScale);
        }
    }
}
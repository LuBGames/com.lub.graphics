using UnityEngine;

namespace LuB.Graphics
{
    public class FogController : MonoBehaviour
    {
        public Vector3 FogOffset;
        public Vector3 FogAxis;
        public float FogScale;

        private void OnValidate()
        {
            UpdateState();
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
using UnityEngine;

namespace LuB.Graphics
{
    [ExecuteAlways]
    public class FogController : MonoBehaviour
    {
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
            var vec = transform.position;
            Shader.SetGlobalVector("FogOffset", transform.position);
            Shader.SetGlobalVector("FogAxis", -transform.forward);
            Shader.SetGlobalFloat("FogScale", FogScale);
        }
    }
}
using UnityEngine;

namespace LuB.Graphics
{
    public class BlendFogSettings : MonoBehaviour
    {
        [SerializeField] private FogSet[] _skyboxes;

        private void Update()
        {
            // float blend = transform.position.x / MapBuilder.HorizontalOffset;
            // blend = Mathf.Clamp(blend, 0f, MapBuilder.HorizontalOffset * 1f);
            // int first = Mathf.FloorToInt(blend);
            // int second = Mathf.CeilToInt(blend);
            // blend -= first;
            //
            // FogSet firstSet = _skyboxes[first];
            // FogSet secondSet = _skyboxes[Mathf.Min(second, _skyboxes.Length-1)];
            //
            // Shader.SetGlobalColor("TopColorSkybox", Color.Lerp(firstSet.TopCollor, secondSet.TopCollor, blend));
            // Shader.SetGlobalColor("BottomColorSkybox", Color.Lerp(firstSet.BottomCollor, secondSet.BottomCollor, blend));
            // Shader.SetGlobalVector("UpSkybox", Vector3.Lerp(firstSet.UpVector, secondSet.UpVector, blend));
            // Shader.SetGlobalFloat("ExpSkybox", Mathf.Lerp(firstSet.Exponent, secondSet.Exponent, blend));
        }

        [System.Serializable]
        private struct FogSet
        {
            [SerializeField, ColorUsage(false)] public Color TopCollor;
            [SerializeField, ColorUsage(false)] public Color BottomCollor;
            [SerializeField] public Vector3 UpVector;
            [SerializeField] public float Exponent;
        }
    }
}
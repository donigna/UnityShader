using UnityEngine;

[ImageEffectAllowedInSceneView, ExecuteInEditMode]
public class ColorSplit : MonoBehaviour
{
    public Vector2 redOffset;
    public Vector2 greenOffset;
    public Vector2 blueOffset;

    private Camera cam;
    private Shader shader;
    private Material material;

    void OnPreCull()
    {
        if (cam == null) cam = GetComponent<Camera>();
        if (shader == null) shader = Shader.Find("Custom/Effects/ColorSplit");
        if (material == null) material = new Material(shader);
    }

    void OnDisable()
    {
#if UNITY_EDITOR
        if (Application.isPlaying) Destroy(material);
        else DestroyImmediate(material);
#else
        Destroy(material);
#endif
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (cam == null || material == null) Graphics.Blit(source, destination);
        else
        {
            material.SetVector("_ROffset", redOffset);
            material.SetVector("_GOffset", greenOffset);
            material.SetVector("_BOffset", blueOffset);
            Graphics.Blit(source, destination, material);
        }
    }
}

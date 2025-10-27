using UnityEditor;

[InitializeOnLoad]
public static class EditorShaderSettings
{
    static EditorShaderSettings()
    {
        ShaderGlobals.SetDefaults();
    }
}
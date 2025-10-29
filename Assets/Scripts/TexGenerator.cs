using System.IO;
using UnityEditor;
using UnityEngine;

public class TexGenerator : EditorWindow
{
    public enum Res { x512 = 512, x1024 = 1024, x2048 = 2048 }
    public enum OutputType { Albedo = 0, Normal = 1 }
    private const string WARNING = "You need to drag a material into the material field!";

    public Material material;
    public Res resolution = Res.x1024;
    public OutputType outputType;


    private void OnGUI()
    {
        EditorGUILayout.Space();
        if (!material)
        {
            EditorGUILayout.HelpBox(WARNING, MessageType.Warning);
        }

        material = EditorGUILayout.ObjectField("Material", material, typeof(Material), false, GUILayout.MinWidth(350)) as Material;

        resolution = (Res)EditorGUILayout.EnumPopup("Output Resolution", resolution);

        outputType = (OutputType)EditorGUILayout.EnumPopup("Output Type", outputType);

        EditorGUILayout.Space();
        if (GUILayout.Button("Generate") && material)
        {
            Generate();
        }
    }

    private void Generate()
    {
        string path = EditorUtility.SaveFilePanel(
            "Save", AssetDatabase.GetAssetPath(material), material.name, "png"
        );

        if (!string.IsNullOrEmpty(path))
        {
            RenderTexture tempRT = RenderTexture.GetTemporary((int)resolution, (int)resolution);
            Graphics.Blit(Texture2D.blackTexture, tempRT, material, (int)outputType); ;

            Texture2D output = new Texture2D(tempRT.width, tempRT.height, TextureFormat.RGBA32, false);
            RenderTexture.active = tempRT;

            output.ReadPixels(new Rect(0, 0, tempRT.width, tempRT.height), 0, 0);
            output.Apply();
            output.filterMode = FilterMode.Bilinear;
            File.WriteAllBytes(path, output.EncodeToPNG());
            RenderTexture.ReleaseTemporary(tempRT);
            RenderTexture.active = null;
            if (path.Contains("Assets")) AssetDatabase.Refresh();
        }
    }

    [MenuItem("Tools/Kuwiku/Texture Generator", false, 1)]
    public static void ShowWindows() => GetWindow(typeof(TexGenerator));
}

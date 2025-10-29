using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable, PostProcess(typeof(ScanlineRenderer),
    PostProcessEvent.AfterStack, "Custom/Scanline", allowInSceneView: true)]
public class Scanline : PostProcessEffectSettings
{
    [Range(144, 1080)]
    public IntParameter height = new IntParameter() { value = 720 };
    public ColorParameter color = new ColorParameter() { value = Color.black };
    public FloatParameter speed = new FloatParameter() { value = 1f };
}

public sealed class ScanlineRenderer : PostProcessEffectRenderer<Scanline>
{
    private const string SHADER = "Hidden/Kuwiku/Effects/Scanline";

    public override void Render(PostProcessRenderContext context)
    {
        PropertySheet sheet = context.propertySheets.Get(Shader.Find(SHADER));
        sheet.properties.SetInt("_Height", settings.height);
        sheet.properties.SetColor("_Color", settings.color);
        sheet.properties.SetFloat("_Speed", settings.speed);
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}
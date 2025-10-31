

using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using UnityEngine.Scripting;

[Serializable, PostProcess(typeof(ColorReplaceRenderer), PostProcessEvent.BeforeStack, "Custom/ColorReplace", allowInSceneView: false), Preserve]
public sealed class ColorReplace : PostProcessEffectSettings
{
    public ColorParameter find = new ColorParameter { value = Color.white };
    public ColorParameter replace = new ColorParameter { value = Color.white };
    [Range(0, 1)]
    public FloatParameter threshold = new FloatParameter { value = 0.1f };
    [Range(0, 1)]
    public FloatParameter mix = new FloatParameter { value = 0 };
    [Range(0, 1)]
    public FloatParameter smooth = new FloatParameter { value = 0 };

    public override bool IsEnabledAndSupported(PostProcessRenderContext context)
    {
        return base.IsEnabledAndSupported(context) && mix > 0;
    }
}

[Preserve]
public sealed class ColorReplaceRenderer : PostProcessEffectRenderer<ColorReplace>
{
    private const string SHADER = "Hidden/ColorReplacementShader";

    public override void Render(PostProcessRenderContext context)
    {
        if (settings.IsEnabledAndSupported(context))
        {
            PropertySheet sheet = context.propertySheets.Get(Shader.Find(SHADER));
            sheet.properties.SetColor("_ColorFind", settings.find);
            sheet.properties.SetColor("_ColorReplace", settings.replace);
            sheet.properties.SetFloat("_Threshold", settings.threshold);
            sheet.properties.SetFloat("_Mix", settings.mix);
            sheet.properties.SetFloat("_Smooth", settings.smooth);
            context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
        }
        else
        {
            context.command.BuiltinBlit(context.source, context.destination);
        }
    }
}
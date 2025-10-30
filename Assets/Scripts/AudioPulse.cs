using UnityEditor.PackageManager.UI;
using UnityEngine;

[RequireComponent(typeof(AudioSource))]
public class AudioPulse : MonoBehaviour
{
    private const string GLOBAL_RMS = "_GlobalRMS";
    private const int SAMPLES = 512;

    [Range(0.1f, 20)]
    public float speed = 10;
    private float lastRMS;
    private AudioSource audioSource;

    private void Awake()
    {
        audioSource = GetComponent<AudioSource>();
    }

    private void Update()
    {
        float rms = Mathf.Lerp(lastRMS, GetRMS(), Time.deltaTime * speed);
        Shader.SetGlobalFloat(GLOBAL_RMS, rms);
        lastRMS = rms;
    }

    private float GetRMS()
    {
        float[] samples = new float[SAMPLES];
        audioSource.GetOutputData(samples, 0);
        float total = 0;
        foreach (float sample in samples) total += sample * sample;
        return Mathf.Sqrt(total / samples.Length);
    }
}
using UnityEngine;

[ExecuteAlways]
public class Billboard : MonoBehaviour
{
    public float yOffset = 180;

    private void OnWillRenderObject()
    {
        Vector3 targetPos = Camera.current.transform.position;
        Vector3 lookDir = (targetPos - transform.position);
        Quaternion lookR = Quaternion.LookRotation(lookDir, Vector3.up);
        transform.rotation = lookR * Quaternion.Euler(0, yOffset, 0);
    }
}
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Graphic))]
public class MaskableUI : MonoBehaviour
{
    private Graphic graphic;

    private void Awake()
    {
        graphic = GetComponent<Graphic>();
    }

    private void Start()
    {
        UpdateMask();
    }

    private void UpdateMask()
    {
        AlphaMask alphaMask = GetComponentInParent<AlphaMask>();
        if (alphaMask != null)
        {
            graphic.material = alphaMask.GetModifiedMaterial(graphic.material);
        }
    }
}
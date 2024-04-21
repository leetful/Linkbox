using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Rendering;
using UnityEngine.XR;

[RequireComponent(typeof(Image))]
public class AlphaMaskVR : MonoBehaviour, IMaterialModifier
{
    private Image maskImage;
    private Material maskMaterial;

    private void Awake()
    {
        maskImage = GetComponent<Image>();
    }

    private void OnEnable()
    {
        // Create a new material using the "UI/Default" shader
        maskMaterial = new Material(Shader.Find("UI/Default"));

        // Get the mask texture from the Image component's sprite
        Texture2D maskTexture = maskImage.sprite.texture;

        // Set the mask texture as the main texture of the material
        maskMaterial.mainTexture = maskTexture;

        // Enable keyword for alpha masking
        maskMaterial.EnableKeyword("UNITY_UI_ALPHACLIP");

        // Enable VR support for the mask material
        maskMaterial.EnableKeyword("UNITY_UI_SINGLE_PASS_STEREO");
    }

    private void OnDisable()
    {
        // Clean up the mask material when the component is disabled
        if (maskMaterial != null)
        {
            DestroyImmediate(maskMaterial);
            maskMaterial = null;
        }
    }

    public Material GetModifiedMaterial(Material baseMaterial)
    {
        // Clone the base material and set the stencil properties for masking
        Material modifiedMaterial = new Material(baseMaterial);
        modifiedMaterial.SetInt("_StencilComp", (int)CompareFunction.Equal);
        modifiedMaterial.SetInt("_Stencil", 1);
        modifiedMaterial.SetInt("_StencilOp", (int)StencilOp.Keep);
        modifiedMaterial.SetInt("_StencilWriteMask", 255);
        modifiedMaterial.SetInt("_StencilReadMask", 255);
        modifiedMaterial.SetInt("_ColorMask", 15);

        // Enable VR support for the modified material
        modifiedMaterial.EnableKeyword("UNITY_UI_SINGLE_PASS_STEREO");

        return modifiedMaterial;
    }

    private void OnRectTransformDimensionsChange()
    {
        // Update the mask when the dimensions of the RectTransform change
        UpdateMask();
    }

    private void UpdateMask()
    {
        // Create a temporary render texture to hold the mask
        RenderTexture tempRenderTexture = RenderTexture.GetTemporary(
            maskImage.sprite.texture.width,
            maskImage.sprite.texture.height,
            0,
            RenderTextureFormat.Default,
            RenderTextureReadWrite.Linear
        );

        // Enable VR support for the temporary render texture
        tempRenderTexture.vrUsage = VRTextureUsage.TwoEyes;

        // Render the mask image to the temporary render texture
        Graphics.Blit(maskImage.sprite.texture, tempRenderTexture, maskMaterial);

        // Set the rendered texture as the main texture of the mask material
        maskMaterial.mainTexture = tempRenderTexture;

        // Release the temporary render texture
        RenderTexture.ReleaseTemporary(tempRenderTexture);
    }
}
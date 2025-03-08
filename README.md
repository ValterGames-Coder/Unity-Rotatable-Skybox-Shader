# Unity-Rotatable-Skybox-Shader
## How use in code:
```cs
using UnityEngine;

public class SkyboxRotate : MonoBehaviour
{
    #region --- Variables ---

    [SerializeField] private Material skyboxMaterial;
    [SerializeField] private float rotateSpeed;
    private float _rotation;

    #endregion

    #region --- Unity Methods ---
    private void LateUpdate()
    {
        _rotation = (Time.time * rotateSpeed) % 360;
        skyboxMaterial.SetFloat("_RotationX", _rotation);
        skyboxMaterial.SetFloat("_RotationY", _rotation);
        skyboxMaterial.SetFloat("_RotationZ", _rotation);
    }

    #endregion
}
```

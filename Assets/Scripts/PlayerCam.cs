using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CameraControl : MonoBehaviour
{
    private float yRotate = 0f;
    private float xRotate = 0f;
    public float sensX;
    public float sensY;

    public Transform playBody;
    // Start is called before the first frame update
    void Start()
    {
        // lock cursor at the center of the screen
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    // Update is called once per frame
    void Update()
    {
        float mouseX = Input.GetAxisRaw("Mouse X") * Time.deltaTime * sensX;
        float mouseY = Input.GetAxisRaw("Mouse Y") * Time.deltaTime * sensY;
        yRotate += mouseX;
        xRotate -= mouseY;
        xRotate = Mathf.Clamp(xRotate, -90f, 90f);

        // rotate camera
        transform.rotation = Quaternion.Euler(xRotate, yRotate, 0);  
        playBody.Rotate(Vector3.up * mouseX);      
    }
}

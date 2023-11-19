using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class ShowFPS : MonoBehaviour
{
    public float timer, refresh, aveFramerate;
    public string display = "fps {0}";
    public TMP_Text canvasText;
    // When use render mode: screen space - camera
    public Camera cam;
    // Start is called before the first frame update
    void Start()
    {
        cam = Camera.main;
    }

    // Update is called once per frame
    void Update()
    {
        float timelapse = Time.smoothDeltaTime;
        timer = timer <= 0 ? refresh : timer -= timelapse;
        if(timer <= 0)
        {
            aveFramerate = (int) (1f / timelapse);
            canvasText.text = string.Format(display, aveFramerate.ToString());
        }

    }
}

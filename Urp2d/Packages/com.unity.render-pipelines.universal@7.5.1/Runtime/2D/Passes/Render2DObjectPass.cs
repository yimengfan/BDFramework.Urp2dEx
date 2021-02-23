using System.Collections.Generic;
using UnityEngine.Rendering;
using UnityEngine.Profiling;
using UnityEngine.Rendering.Universal;

namespace UnityEngine.Experimental.Rendering.Universal
{
    internal class Render2DObjectPass : ScriptableRenderPass
    {
        static SortingLayer[] s_SortingLayers;
        Renderer2DData        m_Renderer2DData;


        readonly List<ShaderTagId> k_ShaderTags = new List<ShaderTagId>() { };

        private string renderFeaturePassTag = "";

        //Draw setting
        RenderQueueType                    renderQueueType;
        FilteringSettings                  m_FilteringSettings;
        RenderObjects.CustomCameraSettings m_CameraSettings;

        public Render2DObjectPass(Renderer2DData rendererData, RenderPassEvent renderPassEvent, string[] lightModeTags, RenderQueueType renderQueueType, int layerMask, RenderObjects.CustomCameraSettings cameraSettings)
        {
            renderFeaturePassTag = "RenderFeature " + lightModeTags[0];
            //Draw setting 相关流程
            this.renderPassEvent = renderPassEvent;
            this.renderQueueType = renderQueueType;
            RenderQueueRange renderQueueRange = (renderQueueType == RenderQueueType.Transparent) ? RenderQueueRange.transparent : RenderQueueRange.opaque;
            m_FilteringSettings = new FilteringSettings(renderQueueRange, layerMask);
            if (s_SortingLayers == null) s_SortingLayers = SortingLayer.layers;
            this.m_CameraSettings = cameraSettings;
            //Tag
            for (int i = 0; i < lightModeTags.Length; i++)
            {
                var         tag = lightModeTags[i];
                ShaderTagId sid = new ShaderTagId(tag);
                k_ShaderTags.Add(sid);
            }

            //
            m_Renderer2DData = rendererData;
        }

        public void GetTransparencySortingMode(Camera camera, ref SortingSettings sortingSettings)
        {
            TransparencySortMode mode = camera.transparencySortMode;

            if (mode == TransparencySortMode.Default)
            {
                mode = m_Renderer2DData.transparencySortMode;
                if (mode == TransparencySortMode.Default) mode = camera.orthographic ? TransparencySortMode.Orthographic : TransparencySortMode.Perspective;
            }

            if (mode == TransparencySortMode.Perspective)
            {
                sortingSettings.distanceMetric = DistanceMetric.Perspective;
            }
            else if (mode == TransparencySortMode.Orthographic)
            {
                sortingSettings.distanceMetric = DistanceMetric.Orthographic;
            }
            else
            {
                sortingSettings.distanceMetric = DistanceMetric.CustomAxis;
                sortingSettings.customAxis     = m_Renderer2DData.transparencySortAxis;
            }
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            bool isLitView = true;

#if UNITY_EDITOR
            if (renderingData.cameraData.isSceneViewCamera) isLitView = UnityEditor.SceneView.currentDrawingSceneView.sceneLighting;

            if (renderingData.cameraData.camera.cameraType == CameraType.Preview) isLitView = false;

            if (!Application.isPlaying) s_SortingLayers = SortingLayer.layers;
#endif
            Camera camera = renderingData.cameraData.camera;

            FilteringSettings filterSettings = new FilteringSettings();
            filterSettings.renderQueueRange   = RenderQueueRange.all;
            filterSettings.layerMask          = -1;
            filterSettings.renderingLayerMask = 0xFFFFFFFF;
            filterSettings.sortingLayerRange  = SortingLayerRange.all;


            CommandBuffer   cmd               = CommandBufferPool.Get("RenderFeature Unlit");
            DrawingSettings unlitDrawSettings = CreateDrawingSettings(k_ShaderTags, ref renderingData, SortingCriteria.CommonTransparent);

            CoreUtils.SetRenderTarget(cmd, colorAttachment, depthAttachment, ClearFlag.None, Color.white);
            cmd.SetGlobalTexture("_ShapeLightTexture0", Texture2D.blackTexture);
            cmd.SetGlobalTexture("_ShapeLightTexture1", Texture2D.blackTexture);
            cmd.SetGlobalTexture("_ShapeLightTexture2", Texture2D.blackTexture);
            cmd.SetGlobalTexture("_ShapeLightTexture3", Texture2D.blackTexture);
            cmd.SetGlobalFloat("_UseSceneLighting", isLitView ? 1.0f : 0.0f);
            cmd.SetGlobalColor("_RendererColor", Color.white);
            cmd.EnableShaderKeyword("USE_SHAPE_LIGHT_TYPE_0");
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);

            Profiler.BeginSample("RenderFeature Unlit");
            context.DrawRenderers(renderingData.cullResults, ref unlitDrawSettings, ref filterSettings);
            Profiler.EndSample();

            RenderingUtils.RenderObjectsWithError(context, ref renderingData.cullResults, camera, filterSettings, SortingCriteria.None);
        }
    }
}
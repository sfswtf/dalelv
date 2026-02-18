import React, { useState, useRef, useEffect } from 'react';
import { motion } from 'framer-motion';
import { useVideoStore } from '../../stores/videoStore';

interface ParallaxHeroProps {
  children: React.ReactNode;
  imageUrl: string;
  videoUrl?: string;
  /** When true, video loops as background instead of playing once as intro */
  loopVideo?: boolean;
}

export const ParallaxHero: React.FC<ParallaxHeroProps> = ({ children, imageUrl, videoUrl, loopVideo = false }) => {
  const [imageLoaded, setImageLoaded] = useState(false);
  const [videoReady, setVideoReady] = useState(false);
  const [videoEnded, setVideoEnded] = useState(false);
  const [videoError, setVideoError] = useState(false);
  const [videoPlaying, setVideoPlaying] = useState(false);
  const { setVideoEnded: setGlobalVideoEnded } = useVideoStore();
  const videoRef = useRef<HTMLVideoElement>(null);

  const showContent = () => {
    setVideoEnded(true);
    setGlobalVideoEnded(true);
  };

  useEffect(() => {
    const video = videoRef.current;
    if (video && videoUrl) {
      // Reset all states when video URL changes
      setVideoEnded(false);
      setVideoError(false);
      setVideoReady(false);
      setVideoPlaying(false);
      setGlobalVideoEnded(false);
      
      // Set a timeout fallback - if video doesn't load in 2 seconds, show content with image fallback
      const timeoutId = setTimeout(() => {
        if (!videoEnded && !videoError && !videoPlaying) {
          console.warn('Video loading timeout, showing content with image fallback');
          setVideoError(true);
          showContent();
        }
      }, 2000);

      // Wait for video to be ready to play
      const handleCanPlay = () => {
        setVideoReady(true);
        // Try to play video
        video.play().then(() => {
          setVideoPlaying(true);
          if (loopVideo) showContent(); // Loop mode: content ready when playing
        }).catch(err => {
          console.error('Error playing video:', err);
          setVideoError(true);
          showContent();
        });
      };

      const handlePlaying = () => {
        setVideoPlaying(true);
      };

      const handleError = () => {
        console.error('Video failed to load');
        setVideoError(true);
        showContent();
      };

      video.addEventListener('canplay', handleCanPlay);
      video.addEventListener('playing', handlePlaying);
      video.addEventListener('error', handleError);

      // Load video
      video.load();

      return () => {
        clearTimeout(timeoutId);
        video.removeEventListener('canplay', handleCanPlay);
        video.removeEventListener('playing', handlePlaying);
        video.removeEventListener('error', handleError);
      };
    } else {
      // No video, wait for image to load first
      if (!videoUrl) {
        // If no video, we still want to wait for image
        // Image loading will trigger content display
      }
    }
  }, [videoUrl, loopVideo, setGlobalVideoEnded]);

  const handleVideoEnd = () => {
    if (loopVideo) return; // Loop mode: video handles its own looping
    // Show image background after video ends
    showContent();
    if (videoRef.current) {
      videoRef.current.style.display = 'none';
    }
  };

  const handleVideoError = () => {
    console.error('Video failed to load');
    setVideoError(true);
    showContent();
  };

  // Determine if content should be visible
  const shouldShowContent = loopVideo
    ? (videoPlaying || videoReady) || videoError || imageLoaded
    : (videoUrl && videoPlaying && videoEnded) ||
      (videoUrl && videoError && imageLoaded) ||
      (!videoUrl && imageLoaded);

  return (
    <div className="fixed top-0 left-0 w-full h-screen z-0 overflow-hidden bg-neutral-900">
      <div className="absolute inset-0">
        {/* Video background - plays first if videoUrl is provided */}
        {videoUrl && (loopVideo || (!videoEnded && !videoError)) && (
          <video
            ref={videoRef}
            className="w-full h-full object-cover"
            playsInline
            muted
            loop={loopVideo}
            autoPlay={loopVideo}
            onEnded={handleVideoEnd}
            onError={handleVideoError}
            preload="auto"
            style={{
              opacity: (loopVideo ? videoPlaying || videoReady : videoPlaying) ? 1 : 0,
              transition: 'opacity 0.3s ease-in-out'
            }}
          >
            <source src={videoUrl} type={videoUrl.endsWith('.mov') ? 'video/quicktime' : 'video/mp4'} />
          </video>
        )}
        
        {/* Image background - shows after video ends or if no video */}
        <img
          className="w-full h-full object-cover"
          src={imageUrl}
          alt="Background"
          loading="eager"
          decoding="async"
          onLoad={() => {
            setImageLoaded(true);
            // If no video, show content when image loads
            if (!videoUrl) {
              showContent();
            }
            // Loop mode: show content as soon as image loads (video can fade in when ready)
            if (loopVideo) {
              showContent();
            }
          }}
          style={{ 
            opacity: ((!loopVideo && (videoEnded || !videoUrl || videoError)) || (loopVideo && videoError)) && imageLoaded ? 1 : 0,
            transition: 'opacity 0.8s ease-in-out',
            position: (videoUrl && !videoEnded && !videoError) ? 'absolute' : 'relative'
          }}
        />
        {/* No dark overlay - background at full opacity */}
      </div>
      {/* Content - only visible when conditions are met, no flashing */}
      <motion.div 
        className="relative h-screen flex flex-col"
        initial={{ opacity: 0 }}
        animate={{ opacity: shouldShowContent ? 1 : 0 }}
        transition={{ duration: 0.5, ease: "easeOut" }}
        style={{
          visibility: shouldShowContent ? 'visible' : 'hidden'
        }}
      >
        {children}
      </motion.div>
    </div>
  );
}; 
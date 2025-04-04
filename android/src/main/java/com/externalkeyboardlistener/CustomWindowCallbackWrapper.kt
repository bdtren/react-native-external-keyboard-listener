package com.externalkeyboardlistener

import android.view.ActionMode
import android.view.KeyEvent
import android.view.Menu
import android.view.MenuItem
import android.view.MotionEvent
import android.view.SearchEvent
import android.view.View
import android.view.Window
import android.view.WindowManager
import android.view.accessibility.AccessibilityEvent

class CustomWindowCallbackWrapper(
  val originalCallback: Window.Callback,
  private val onKeyEventListener: (KeyEvent) -> Unit
) : Window.Callback {

  override fun dispatchKeyEvent(event: KeyEvent?): Boolean {
    event?.let {
      onKeyEventListener(it)
    }
    return originalCallback.dispatchKeyEvent(event)
  }

  // Delegate all other methods to the original callback
//  override fun dispatchKeyEventPreIme(event: KeyEvent?) = originalCallback.dispatchKeyEventPreIme(event)
  override fun dispatchKeyShortcutEvent(event: KeyEvent?) = originalCallback.dispatchKeyShortcutEvent(event)
  override fun dispatchTouchEvent(event: MotionEvent?) = originalCallback.dispatchTouchEvent(event)
  override fun dispatchTrackballEvent(event: MotionEvent?) = originalCallback.dispatchTrackballEvent(event)
  override fun dispatchGenericMotionEvent(event: MotionEvent?) = originalCallback.dispatchGenericMotionEvent(event)
  override fun dispatchPopulateAccessibilityEvent(event: AccessibilityEvent?) = originalCallback.dispatchPopulateAccessibilityEvent(event)
  override fun onCreatePanelView(featureId: Int) = originalCallback.onCreatePanelView(featureId)
  override fun onCreatePanelMenu(featureId: Int, menu: Menu) = originalCallback.onCreatePanelMenu(featureId, menu)
  override fun onPreparePanel(featureId: Int, view: View?, menu: Menu) = originalCallback.onPreparePanel(featureId, view, menu)
  override fun onMenuOpened(featureId: Int, menu: Menu) = originalCallback.onMenuOpened(featureId, menu)
  override fun onMenuItemSelected(featureId: Int, item: MenuItem) = originalCallback.onMenuItemSelected(featureId, item)
  override fun onWindowAttributesChanged(attrs: WindowManager.LayoutParams?) = originalCallback.onWindowAttributesChanged(attrs)
  override fun onContentChanged() = originalCallback.onContentChanged()
  override fun onWindowFocusChanged(hasFocus: Boolean) = originalCallback.onWindowFocusChanged(hasFocus)
  override fun onAttachedToWindow() = originalCallback.onAttachedToWindow()
  override fun onDetachedFromWindow() = originalCallback.onDetachedFromWindow()
  override fun onPanelClosed(featureId: Int, menu: Menu) = originalCallback.onPanelClosed(featureId, menu)
  override fun onSearchRequested() = originalCallback.onSearchRequested()
  override fun onSearchRequested(searchEvent: SearchEvent?) = originalCallback.onSearchRequested(searchEvent)
  override fun onWindowStartingActionMode(callback: ActionMode.Callback?) = originalCallback.onWindowStartingActionMode(callback)
  override fun onWindowStartingActionMode(callback: ActionMode.Callback?, type: Int) = originalCallback.onWindowStartingActionMode(callback, type)
  override fun onActionModeStarted(mode: ActionMode?) = originalCallback.onActionModeStarted(mode)
  override fun onActionModeFinished(mode: ActionMode?) = originalCallback.onActionModeFinished(mode)
}
